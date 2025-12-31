open! Core
open Crystal
open Js_of_ocaml
module Bonsai = Bonsai.Cont
open Bonsai_web.Cont
open Bonsai.Let_syntax
module Form = Bonsai_web_ui_form.With_manual_view

module Weight_by = struct
  type t =
    | Event
    | Date
  [@@deriving compare, enumerate, equal, sexp_of]

  let to_string = function
    | Event -> "Event"
    | Date -> "Date"
  ;;
end

type t =
  { events : Event.t list
  ; scores : (string, Scores.t) List.Assoc.t
  }
[@@deriving fields]

let sort_events events =
  List.sort events ~compare:(fun e1 e2 ->
    let c = [%compare: Date.t option] (Event.date e1) (Event.date e2) in
    if c <> 0 then c else [%compare: Event_id.t] (Event.id e1) (Event.id e2))
;;

let create events scores =
  let events = sort_events events in
  let scores =
    String.Map.map_keys_exn scores ~f:(fun respondent ->
      let respondent =
        match String.split respondent ~on:'@' with
        | name :: _ -> name
        | _ -> respondent
      in
      String.prefix respondent 10)
    |> Map.to_alist
    |> List.sort ~compare:(fun (_, a) (_, b) ->
      let a = Scores.total a in
      let b = Scores.total b in
      Comparable.reverse [%compare: float] a b)
  in
  { events; scores }
;;

let cumulative_scores t =
  let scores, events =
    let scores =
      List.Assoc.map t.scores ~f:(fun scores ->
        0.
        :: (t.events
            |> List.folding_map ~init:0. ~f:(fun sum event ->
              let event_id = Event.id event in
              let event_score = Scores.event_score scores event_id in
              let new_cumulative_score =
                if Float.is_nan event_score then sum else sum +. event_score
              in
              new_cumulative_score, new_cumulative_score)))
    in
    scores, t.events
  in
  scores, events
;;

let min_finite_score t =
  let cumulative_scores, _ = cumulative_scores t in
  let min_finite_score =
    cumulative_scores
    |> List.map ~f:snd
    |> List.concat
    |> List.filter ~f:Float.is_finite
    |> List.min_elt ~compare:Float.compare
    |> Option.value ~default:0.
  in
  min_finite_score
;;

let max_finite_score t =
  let cumulative_scores, _ = cumulative_scores t in
  let max_score =
    cumulative_scores
    |> List.map ~f:snd
    |> List.concat
    |> List.filter ~f:Float.is_finite
    |> List.max_elt ~compare:Float.compare
    |> Option.value ~default:0.
  in
  max_score
;;

let total_scores t = List.Assoc.map t.scores ~f:Scores.total

let hover_text ~respondent ~date ~label =
  let date = date |> Option.value_map ~default:"" ~f:Date.to_string in
  [%string "<b>%{respondent}</b><br>%{date}<br>%{label}"]
;;

let component ~start_date ~end_date events scores graph =
  let weight_by, set_weight_by = Bonsai.state Weight_by.Event graph in
  let radio =
    let radio =
      Form.Elements.Radio_buttons.enumerable
        (module Weight_by)
        ~style:(return Vdom_input_widgets.Selectable_style.Native)
        ~to_string:Weight_by.to_string
        ~layout:`Horizontal
        graph
    in
    let sync_with =
      Form.Dynamic.sync_with
        ~equal:[%equal: Weight_by.t]
        ~store_value:
          (let%arr weight_by = weight_by in
           Some weight_by)
        ~store_set:set_weight_by
        radio
        graph
    in
    (* TODO: When we upgrade bonsai, [sync_with] should return unit and we can delete this line. *)
    Bonsai.( *> ) sync_with radio
  in
  let t = create events scores in
  let total_scores = total_scores t in
  let cumulative_scores, sorted_events = cumulative_scores t in
  let min_finite_score = min_finite_score t in
  let max_finite_score = max_finite_score t in
  let () =
    Bonsai.Edge.on_change
      ~equal:[%equal: Weight_by.t]
      weight_by
      ~callback:
        (let%arr () = return () in
         fun weight_by ->
           let plotly_data =
             List.map total_scores ~f:(fun (respondent, score) ->
               let respondent_scores =
                 List.Assoc.find_exn cumulative_scores respondent ~equal:[%equal: string]
               in
               let x_axis_values, y_axis_values, text_values =
                 match weight_by with
                 | Weight_by.Event ->
                   let x = "" :: List.map sorted_events ~f:Event.label in
                   let y = respondent_scores in
                   let text =
                     ""
                     :: List.map sorted_events ~f:(fun e ->
                       hover_text ~respondent ~date:(Event.date e) ~label:(Event.label e))
                   in
                   x, y, text
                 | Weight_by.Date ->
                   let scores_for_events =
                     List.zip_exn sorted_events (List.tl_exn respondent_scores)
                   in
                   let dated_scores =
                     List.filter_map scores_for_events ~f:(fun (event, score) ->
                       Option.map (Event.date event) ~f:(fun date -> date, score, event))
                   in
                   let x =
                     Date.to_string start_date
                     :: List.map dated_scores ~f:(fun (d, _, _) -> Date.to_string d)
                   in
                   let y =
                     List.hd_exn respondent_scores
                     :: List.map dated_scores ~f:(fun (_, s, _) -> s)
                   in
                   let text =
                     ""
                     :: List.map dated_scores ~f:(fun (date, _, event) ->
                       hover_text ~respondent ~date:(Some date) ~label:(Event.label event))
                   in
                   x, y, text
               in
               let trace : Crystal_plotly.Data.Line.t =
                 { x =
                     Array.of_list
                       (List.map x_axis_values ~f:(fun s ->
                          Crystal_plotly.Float_or_string.String s))
                 ; y = Array.of_list y_axis_values
                 ; type_ = "scatter"
                 ; mode = "lines"
                 ; name =
                     [%string "%{respondent}: %{Float.to_string_hum ~decimals:2 score}"]
                 ; line =
                     { color = None
                     ; width = 1
                     ; shape = Some "spline"
                     ; smoothing = Some 0.3
                     }
                 ; hovertemplate = Some "%{text}<extra></extra>"
                 ; text = Some (Array.of_list text_values)
                 }
               in
               Crystal_plotly.Data.Line trace)
           in
           let layout =
             let y_range =
               let upper_bound = max_finite_score *. 1.1 in
               let lower_bound = min_finite_score *. 1.1 in
               [ lower_bound; upper_bound ]
             in
             let xaxis : Crystal_plotly.Layout.xaxis =
               let range =
                 match weight_by with
                 | Date ->
                   let start_date = Date.add_days start_date (-3) |> Date.to_string in
                   let end_date = Date.add_days end_date 3 |> Date.to_string in
                   Some
                     [ Crystal_plotly.Float_or_string.String start_date
                     ; Crystal_plotly.Float_or_string.String end_date
                     ]
                 | Event -> None
               in
               { title = Weight_by.to_string weight_by
               ; showticklabels = true
               ; zeroline = false
               ; fixedrange = false
               ; range
               ; tickvals = None
               ; ticktext = None
               }
             in
             let yaxis : Crystal_plotly.Layout.yaxis =
               { autorange = None
               ; automargin = None
               ; tickfont = None
               ; fixedrange = false
               ; range = Some y_range
               }
             in
             let layout : Crystal_plotly.Layout.t =
               { title = { text = "" }
               ; yaxis
               ; xaxis
               ; shapes = []
               ; margin = { l = 50; r = 50; t = 50; b = 50 }
               ; height = 600
               ; showlegend = true
               }
             in
             layout
           in
           let config : Crystal_plotly.Config.t =
             { display_mode_bar = false; displaylogo = false }
           in
           Effect.of_sync_fun
             (fun () ->
                Crystal_plotly.Plotly.react
                  (Dom_html.getElementById_exn "standings-plot-div")
                  plotly_data
                  layout
                  config)
             ())
      graph
  in
  let%arr { view; _ } = radio in
  Vdom.Node.div [ Vdom.Node.div ~attrs:[ Vdom.Attr.id "standings-plot-div" ] []; view ]
;;
