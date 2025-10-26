open! Core
open Crystal
open Js_of_ocaml
module Bonsai = Bonsai.Cont
open Bonsai_web.Cont
open Bonsai.Let_syntax
module Form = Bonsai_web_ui_form.With_manual_view

module Sort_by = struct
  type t =
    | Date
    | Event_label
  [@@deriving compare, enumerate, equal, sexp_of]

  let to_string = function
    | Date -> "Date"
    | Event_label -> "Event Label"
  ;;
end

type t =
  { events : Event.t list
  ; scores : (string, Scores.t) List.Assoc.t
  ; sort_by : Sort_by.t Bonsai.t
  }
[@@deriving fields]

let create events scores sort_by =
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
  { events; scores; sort_by }
;;

let cumulative_scores_by_label ~events ~scores =
  events
  |> List.folding_map ~init:0. ~f:(fun sum event ->
    let event_id = Event.id event in
    let event_score = Scores.event_score scores event_id in
    let new_cumulative_score =
      if Float.is_nan event_score then sum else sum +. event_score
    in
    new_cumulative_score, new_cumulative_score)
;;

let cumulative_scores_by_label (t : t) =
  List.Assoc.map t.scores ~f:(fun scores ->
    cumulative_scores_by_label ~events:t.events ~scores)
;;

let cumulative_scores_by_date ~events ~scores =
  events
  |> List.sort ~compare:(fun event event' ->
    [%compare: Date.t option] (Event.date event) (Event.date event'))
  |> List.folding_map ~init:0. ~f:(fun sum event ->
    let event_id = Event.id event in
    let event_score = Scores.event_score scores event_id in
    let new_cumulative_score =
      if Float.is_nan event_score then sum else sum +. event_score
    in
    new_cumulative_score, new_cumulative_score)
;;

let cumulative_scores_by_date (t : t) =
  List.Assoc.map t.scores ~f:(fun scores ->
    cumulative_scores_by_date ~events:t.events ~scores)
;;

let cumulative_scores t =
  match%arr t.sort_by with
  | Date -> cumulative_scores_by_date t
  | Event_label -> cumulative_scores_by_label t
;;

let min_finite_score t =
  let%arr cumulative_scores = cumulative_scores t in
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
  let%arr cumulative_scores = cumulative_scores t in
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

let min_total_score t =
  total_scores t
  |> List.map ~f:snd
  |> List.filter ~f:Float.is_finite
  |> List.min_elt ~compare:Float.compare
  |> Option.value ~default:0.
;;

let max_total_score t =
  total_scores t
  |> List.map ~f:snd
  |> List.filter ~f:Float.is_finite
  |> List.max_elt ~compare:Float.compare
  |> Option.value ~default:0.
;;

let component events scores graph =
  let sort_by, set_sort_by = Bonsai.state Sort_by.Date graph in
  let radio =
    let radio =
      Form.Elements.Radio_buttons.enumerable
        (module Sort_by)
        ~style:(return Vdom_input_widgets.Selectable_style.Native)
        ~to_string:Sort_by.to_string
        ~layout:`Horizontal
        graph
    in
    let sync_with =
      Form.Dynamic.sync_with
        ~equal:[%equal: Sort_by.t]
        ~store_value:
          (let%arr sort_by = sort_by in
           Some sort_by)
        ~store_set:set_sort_by
        radio
        graph
    in
    (* TODO: When we upgrade bonsai, [sync_with] should return unit and we can delete this line. *)
    Bonsai.( *> ) sync_with radio
  in
  let t = create events scores sort_by in
  let total_scores = total_scores t in
  let min_total_score = min_total_score t in
  let max_total_score = max_total_score t in
  let () =
    Bonsai.Edge.on_change
      ~equal:[%equal: Sort_by.t]
      sort_by
      ~callback:
        (let%arr cumulative_scores = cumulative_scores t
         and max_finite_score = max_finite_score t
         and min_finite_score = min_finite_score t in
         fun sort_by ->
           let plotly_data =
             let x_axis_data, sorted_events_for_x =
               match sort_by with
               | Sort_by.Date ->
                 let sorted_events =
                   List.sort events ~compare:(fun event event' ->
                     [%compare: Date.t option] (Event.date event) (Event.date event'))
                 in
                 let dates =
                   List.filter_map sorted_events ~f:(fun event ->
                     Option.map (Event.date event) ~f:Date.to_string)
                 in
                 let x =
                   dates |> List.map ~f:(fun s -> Crystal_plotly.Float_or_string.String s)
                 in
                 x, sorted_events
               | Sort_by.Event_label ->
                 let labels = List.map events ~f:Event.label in
                 let x =
                   labels
                   |> List.map ~f:(fun s -> Crystal_plotly.Float_or_string.String s)
                 in
                 x, events
             in
             List.map t.scores ~f:(fun (respondent, _) ->
               let score =
                 List.Assoc.find_exn total_scores respondent ~equal:[%equal: string]
               in
               let color =
                 let r_zero, g_zero, b_zero = 128., 128., 128. in
                 let r_pos, g_pos, b_pos = 0., 192., 64. in
                 let r_neg, g_neg, b_neg = 192., 0., 64. in
                 let red_val, green_val, blue_val =
                   if Float.is_inf score && Float.is_positive score
                   then r_pos, g_pos, b_pos
                   else if Float.is_inf score && Float.is_negative score
                   then r_neg, g_neg, b_neg
                   else if Float.(score > 0.0)
                   then (
                     let ratio =
                       if Float.equal max_total_score 0.0
                       then 0.0
                       else score /. max_total_score
                     in
                     let r = r_zero +. ((r_pos -. r_zero) *. ratio) in
                     let g = g_zero +. ((g_pos -. g_zero) *. ratio) in
                     let b = b_zero +. ((b_pos -. b_zero) *. ratio) in
                     r, g, b)
                   else if Float.(score < 0.0)
                   then (
                     let ratio =
                       if Float.equal min_total_score 0.0
                       then 0.0
                       else score /. min_total_score
                     in
                     let r = r_zero +. ((r_neg -. r_zero) *. ratio) in
                     let g = g_zero +. ((g_neg -. g_zero) *. ratio) in
                     let b = b_zero +. ((b_neg -. b_zero) *. ratio) in
                     r, g, b)
                   else r_zero, g_zero, b_zero
                 in
                 let red_val, green_val, blue_val =
                   int_of_float red_val, int_of_float green_val, int_of_float blue_val
                 in
                 let clamp_byte = Int.clamp_exn ~min:0 ~max:255 in
                 [%string
                   "rgb(%{clamp_byte red_val#Int}, %{clamp_byte green_val#Int},\n\
                   \                       %{clamp_byte blue_val#Int})"]
               in
               let respondent_scores =
                 List.Assoc.find_exn cumulative_scores respondent ~equal:[%equal: string]
               in
               let y_axis_data =
                 match sort_by with
                 | Event_label -> respondent_scores
                 | Date ->
                   List.zip_exn sorted_events_for_x respondent_scores
                   |> List.filter ~f:(fun (event, _) -> Option.is_some (Event.date event))
                   |> List.map ~f:snd
               in
               let trace : Crystal_plotly.Data.Line.t =
                 { x = Array.of_list x_axis_data
                 ; y = Array.of_list y_axis_data
                 ; type_ = "scatter"
                 ; mode = "lines"
                 ; name =
                     [%string "%{respondent}: %{Float.to_string_hum ~decimals:2 score}"]
                 ; line = { color; width = 1 }
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
                 match sort_by with
                 | Date ->
                   Some
                     [ Crystal_plotly.Float_or_string.String "2025-08-20"
                     ; Crystal_plotly.Float_or_string.String "2025-12-31"
                     ]
                 | Event_label -> None
               in
               { title = Sort_by.to_string sort_by
               ; showticklabels = true
               ; zeroline = false
               ; fixedrange = false
               ; autorange = None
               ; type_ = None
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
