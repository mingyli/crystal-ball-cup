open! Core
open Crystal
open Js_of_ocaml
module Bonsai = Bonsai.Cont
open Bonsai_web.Cont
open Bonsai.Let_syntax
module Query_box = Bonsai_web_ui_query_box
module Form = Bonsai_web_ui_form.With_manual_view
module E = Form.Elements

module Resolution = struct
  include Resolution

  module Option = struct
    module T = struct
      type nonrec t = t option [@@deriving compare, equal, sexp, enumerate]
    end

    include T
    include Comparable.Make (T)

    let to_string = function
      | Some Yes -> "Yes"
      | Some No -> "No"
      | None -> "Pending"
    ;;

    let color = function
      | Some Yes -> Colors.blue
      | Some No -> Colors.orange
      | None -> Colors.gray
    ;;

    let accent_color = function
      | Some Yes -> Colors.light_blue
      | Some No -> Colors.light_orange
      | None -> Colors.light_gray
    ;;
  end
end

module Style =
  [%css
    stylesheet
      {|
      .plots-container {
        display: grid;
        align-items: center;
        grid-template-columns: 1fr 1fr 4fr;
        margin-bottom: 10px;
      }

      .resolution-chip-wrapper {
        font-weight: bold;
        text-align: center;
      }

      .plot-div {
        padding-left: 1rem;
        padding-right: 1rem;
        width: 550px;
        max-width: 550px;
      }

      .query-box-container {
        display: flex;
        justify-content: space-around;
        align-items: center;
        width: 100%;
        margin-bottom: 1rem;
        padding: 0;
      }

      .query-box-item {
        flex: 1;
        margin: 0 0.5rem;
        padding: 0.5rem;
        border: 1px solid #ced4da;
        border-radius: 0.25rem;
        justify-content: center;
        align-items: stretch;
        height: 100%;
      }

      @media (max-width: 768px) {
        .plots-container {
          display: flex;
          flex-direction: column;
          align-items: flex-start;
          margin-bottom: 1rem;
        }

        .plot-div {
          width: 100%;
          min-width: 0;
          padding-left: 0.5rem;
          padding-right: 0.5rem;
        }

        .query-box-container {
          flex-direction: column;
        }

        .query-box-item {
          margin: 0.25rem 0;
          max-width: none;
        }
      }
    |}]

let create_resolutions_checkboxes which_resolutions set_which_resolutions graph =
  let checkboxes =
    E.Checkbox.set
      (module Resolution.Option)
      ~layout:`Horizontal
      ~to_string:Resolution.Option.to_string
      ~style:(Bonsai.return E.Selectable_style.Button_like)
      ~extra_checkbox_attrs:
        (Bonsai.return (fun ~checked ->
           [ {%css|
           font-size: 0.8em;
           padding: 0.2em 0.4em;
           margin: 0.4em;
           cursor: pointer;
         |}
           ]
           @
           if checked
           then
             [ {%css|
            background-color: %{Colors.burgundy};
            color: %{Colors.white};
            border: 3px solid %{Colors.light_gray}
            |}
             ; {%css| &:active {
                        background-color: %{Colors.transparent};
                        color: %{Colors.black};
                        border: 3px solid %{Colors.dark_gray}
                        }
                        |}
             ]
           else
             [ {%css|
               background-color: %{Colors.transparent};
               color: %{Colors.black};
               transform: translate(3px, 3px);
               border: 3px solid %{Colors.light_gray}
            |}
             ; {%css|
              &:active {
              background-color: %{Colors.burgundy};
              color: %{Colors.white};
              border: 3px solid %{Colors.dark_gray}
              }
            |}
             ]))
      ~extra_container_attrs:
        (Bonsai.return
           [ Style.query_box_item; {%css| display: flex; flex-direction: row; |} ])
      (Bonsai.return Resolution.Option.all)
      graph
  in
  let sync_with =
    Form.Dynamic.sync_with
      ~equal:Resolution.Option.Set.equal
      ~store_value:
        (let%arr which_resolutions = which_resolutions in
         Some which_resolutions)
      ~store_set:set_which_resolutions
      checkboxes
      graph
  in
  (* TODO: When we upgrade bonsai, [sync_with] should return unit and we can delete this line. *)
  Bonsai.( *> ) sync_with checkboxes
;;

let create_query_box
      (type a cmp)
      (module M : Bonsai.Comparator with type t = a and type comparator_witness = cmp)
      ~set_state
      ~placeholder_text
      ~(default_value : a)
      ~items
      graph
  =
  Query_box.stringable
    ~filter_strategy:Fuzzy_search_and_score
    ~on_select:set_state
    ~selected_item_attr:(return {%css| background-color: %{Colors.light_gray}; |})
    ~extra_list_container_attr:
      (return
         {%css|
        background: %{Colors.white};
        border: solid 1px %{Colors.black};
        padding: 5px;
        z-index: 9999;
      |})
    ~extra_input_attr:
      (let%arr set_state = set_state in
       Vdom.Attr.many
         [ Vdom.Attr.placeholder placeholder_text
         ; {%css| width: 100%; box-sizing: border-box; |}
         ; Vdom.Attr.on_change (fun _event value ->
             if String.is_empty value then set_state default_value else Effect.Ignore)
         ; Vdom.Attr.on_focus (fun event ->
             Effect.of_sync_fun
               (fun event ->
                  Js.Opt.iter event##.target (fun target ->
                    Js.Opt.iter (Dom_html.CoerceTo.input target) (fun input ->
                      input##select)))
               event)
         ])
    ~extra_attr:(return Style.query_box_item)
    ~modify_input_on_select:(return `Autocomplete)
    (module M)
    items
    graph
;;

let render_plot div_id plotly_data layout =
  Effect.of_sync_fun
    (fun () ->
       Crystal_plotly.Plotly.react
         (Dom_html.getElementById_exn div_id)
         plotly_data
         layout
         { display_mode_bar = false })
    ()
;;

type t =
  { events : Event.t list
  ; responses_and_scores : Responses_and_scores.t String.Map.t
  }
[@@deriving fields]

let create = Fields.create

let respondents t =
  t.responses_and_scores |> Map.keys |> List.sort ~compare:[%compare: string]
;;

let get_responses t event_id =
  List.map (respondents t) ~f:(fun r ->
    let resp_data = Map.find_exn t.responses_and_scores r in
    Map.find_exn
      (resp_data |> Responses_and_scores.responses |> Responses.probabilities)
      event_id)
  |> Array.of_list
;;

let render_plots
      t
      (which_resolutions : Resolution.Option.Set.t)
      (which_events : Which_events.t)
      (which_respondents : Which_respondents.t)
  =
  let events_to_plot =
    match which_events with
    | All ->
      List.filter t.events ~f:(fun event ->
        Set.mem which_resolutions (Event.resolution event))
    | One event -> [ event ]
  in
  let effects =
    List.map events_to_plot ~f:(fun event ->
      let responses =
        get_responses t (Event.id event) |> Array.map ~f:Probability.to_float
      in
      let fill_color, line_color =
        match Event.resolution event with
        | Some Yes -> Colors.very_light_blue, Colors.blue
        | Some No -> Colors.very_light_orange, Colors.orange
        | None -> Colors.very_light_gray, Colors.gray
      in
      let plotly_data =
        let violin : Crystal_plotly.Data.t =
          Violin
            { x = responses
            ; type_ = "violin"
            ; name = ""
            ; orientation = "h"
            ; hoverinfo = "none"
            ; box = { visible = false }
            ; meanline = { visible = true }
            ; side = "positive"
            ; fillcolor = fill_color
            ; line = { color = line_color }
            ; points = false
            }
        in
        let scatter : Crystal_plotly.Data.t =
          match which_respondents with
          | None ->
            Scatter
              { x = responses
              ; y = Array.map responses ~f:(fun _ -> "")
              ; type_ = "scatter"
              ; mode = "markers"
              ; text = Array.of_list (respondents t)
              ; customdata =
                  Array.map responses ~f:(fun p ->
                    let prediction = sprintf "%.2f" p in
                    Crystal_plotly.Data.Scatter.{ prediction })
              ; hovertemplate = "<b>%{customdata.prediction}</b> %{text}<extra></extra>"
              ; marker =
                  { size = 10
                  ; color = Array.map responses ~f:(Fn.const Colors.very_light_gray)
                  }
              ; fill = None
              ; fillcolor = None
              ; line = None
              }
          | One selected_respondent ->
            let respondents, responses =
              Array.zip_exn (respondents t |> Array.of_list) responses
              |> Array.filter_map ~f:(fun (respondent, response) ->
                if String.equal respondent selected_respondent
                then Some (respondent, response)
                else None)
              |> Array.unzip
            in
            let colors = Array.map responses ~f:(Fn.const Colors.burgundy) in
            Scatter
              { x = responses
              ; y = Array.map responses ~f:(fun _ -> "")
              ; type_ = "scatter"
              ; mode = "markers"
              ; text = respondents
              ; customdata =
                  Array.map responses ~f:(fun p ->
                    let prediction = sprintf "%.2f" p in
                    Crystal_plotly.Data.Scatter.{ prediction })
              ; hovertemplate = "<b>%{customdata.prediction}</b> %{text}<extra></extra>"
              ; marker = { size = 10; color = colors }
              ; fill = None
              ; fillcolor = None
              ; line = None
              }
        in
        [ violin; scatter ]
      in
      let layout : Crystal_plotly.Layout.t =
        let layout_height, layout_margin =
          match which_events with
          | All -> 100, { Crystal_plotly.Layout.l = 20; r = 20; b = 20; t = 20 }
          | One _ -> 150, { Crystal_plotly.Layout.l = 20; r = 20; b = 20; t = 40 }
        in
        { title = { text = "" }
        ; yaxis =
            { autorange = None
            ; automargin = None
            ; tickfont = None
            ; fixedrange = true
            ; range = None
            }
        ; xaxis =
            { title = ""
            ; showticklabels = true
            ; zeroline = false
            ; fixedrange = true
            ; range = Some [ 0.; 1. ]
            ; tickvals = Some [ 0.; 0.25; 0.5; 0.75; 1. ]
            ; ticktext = Some [ "0"; "0.25"; "0.5"; "0.75"; "1" ]
            }
        ; shapes = []
        ; margin = layout_margin
        ; height = layout_height
        ; showlegend = false
        }
      in
      let div_id =
        match which_events with
        | All -> [%string "plot-%{Event.id event#Event_id}"]
        | One _ -> "plot-single"
      in
      render_plot div_id plotly_data layout)
  in
  Effect.all_unit effects
;;

let component (t : t) graph =
  let which_resolutions, set_which_resolutions =
    Bonsai.state Resolution.Option.(Set.of_list all) graph
  in
  let which_events, set_which_events = Bonsai.state Which_events.All graph in
  let which_respondents, set_which_respondents =
    Bonsai.state Which_respondents.None graph
  in
  let checkboxes_which_resolutions =
    create_resolutions_checkboxes which_resolutions set_which_resolutions graph
  in
  let query_box_which_events =
    create_query_box
      (module Which_events)
      ~set_state:set_which_events
      ~placeholder_text:"View all events"
      ~default_value:All
      ~items:
        (let%arr () = return () in
         Which_events.All :: List.map (events t) ~f:Which_events.one
         |> Which_events.Set.of_list
         |> Which_events.Map.of_key_set ~f:(function
           | All -> "View all events"
           | One event -> Event.short event))
      graph
  in
  let query_box_which_respondents =
    create_query_box
      (module Which_respondents)
      ~set_state:set_which_respondents
      ~placeholder_text:"No respondent highlighted"
      ~default_value:None
      ~items:
        (let%arr () = return () in
         Which_respondents.None :: List.map (respondents t) ~f:Which_respondents.one
         |> Which_respondents.Set.of_list
         |> Which_respondents.Map.of_key_set ~f:(function
           | None -> "No respondent highlighted"
           | One respondent -> respondent))
      graph
  in
  let () =
    Bonsai.Edge.on_change
      ~equal:[%equal: Resolution.Option.Set.t * Which_events.t * Which_respondents.t]
      (let%arr which_resolutions = which_resolutions
       and which_events = which_events
       and which_respondents = which_respondents in
       which_resolutions, which_events, which_respondents)
      ~callback:
        (let%arr () = return () in
         fun (which_resolutions, which_events, which_respondents) ->
           render_plots t which_resolutions which_events which_respondents)
      graph
  in
  let open Vdom in
  let plots =
    let%arr which_events = which_events
    and set_which_events = set_which_events
    and query_box_which_events = query_box_which_events
    and which_resolutions = which_resolutions in
    let render_resolution_chip event =
      let resolution = Event.resolution event in
      let resolution_style =
        {%css| background-color: %{Resolution.Option.accent_color resolution}; color: %{Resolution.Option.color resolution}; |}
      in
      Node.span
        ~attrs:
          [ {%css|
            display: inline-block;
            padding: 0.2em 0.6em;
            border-radius: 1em;
            font-size: 0.8em;
            text-align: center;
            white-space: nowrap;
            vertical-align: middle;
            line-height: 1;
          |}
          ; resolution_style
          ]
        [ Node.text (Resolution.Option.to_string resolution) ]
    in
    match which_events with
    | One event ->
      [ Node.div
          ~attrs:[]
          [ Node.div
              ~attrs:[ Style.resolution_chip_wrapper ]
              [ render_resolution_chip event ]
          ; Node.div [ Node.text (Event.precise event) ]
          ; Node.div ~attrs:[ Attr.id "plot-single" ] []
          ]
      ]
    | All ->
      let events_in_view =
        List.filter (events t) ~f:(fun event ->
          Set.mem which_resolutions (Event.resolution event))
      in
      List.map events_in_view ~f:(fun event ->
        let resolution = Event.resolution event in
        let resolution_hover_style =
          {%css|
            &:hover {
              background-color: %{Resolution.Option.accent_color resolution};
              color: %{Resolution.Option.color resolution};
            }

            &:active {
              background-color: %{Resolution.Option.color resolution};
              color: %{Colors.white};
            }
            |}
        in
        Node.div
          ~attrs:[ Style.plots_container ]
          [ Node.div
              ~attrs:[ Style.resolution_chip_wrapper ]
              [ render_resolution_chip event ]
          ; Node.a
              ~attrs:
                [ {%css|
                    font-size: 0.8em;
                    color: %{Colors.black};
                    text-decoration: underline;
                    cursor: pointer;
                    padding: 0.2em;
                  |}
                ; resolution_hover_style
                ; Attr.href "#"
                ; Attr.on_click (fun dom_event ->
                    Dom.preventDefault dom_event;
                    Effect.all_unit
                      [ set_which_events (One event)
                      ; Query_box.set_query query_box_which_events (Event.short event)
                      ])
                ]
              [ Node.text [%string "%{Event.id event#Event_id}. %{Event.short event}"] ]
          ; Node.div
              ~attrs:
                [ Attr.id [%string "plot-%{Event.id event#Event_id}"]; Style.plot_div ]
              []
          ])
  in
  let%arr plots = plots
  and query_box_which_events = query_box_which_events
  and query_box_which_respondents = query_box_which_respondents
  and checkboxes_which_resolutions = checkboxes_which_resolutions in
  Node.div
    [ Node.div
        ~attrs:[ Style.query_box_container ]
        [ Form.view checkboxes_which_resolutions
        ; Query_box.view query_box_which_events
        ; Query_box.view query_box_which_respondents
        ]
    ; Node.div plots ~attrs:[ {%css| width: 100%; |} ]
    ]
;;
