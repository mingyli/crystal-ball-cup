open! Core
open Crystal
open Js_of_ocaml
module Bonsai = Bonsai.Cont
open Bonsai_web.Cont
open Bonsai.Let_syntax
module Query_box = Bonsai_web_ui_query_box

module Style =
  [%css
    stylesheet
      {|
      .selected_item {
        background-color: rgba(0, 0, 128, 0.2);
        color: blue;
      }

      .list_container {
        background: white;
        border: solid 1px black;
        padding: 5px;
        z-index: 9999;
      }

      .outcome-chip {
        display: inline-block;
        padding: 0.2em 0.6em;
        border-radius: 1em;
        font-size: 0.8em;
        text-align: center;
        white-space: nowrap;
        vertical-align: middle;
        line-height: 1;
      }

      .outcome-chip-yes {
        background-color: rgba(0, 128, 0, 0.2);
        color: green;
      }

      .outcome-chip-no {
        background-color: rgba(255, 0, 0, 0.2);
        color: red;
      }

      .outcome-chip-pending {
        background-color: rgba(128, 128, 128, 0.2);
        color: rgba(128, 128, 128, 0.8);
      }

      .plots-container {
        display: grid;
        align-items: center;
        grid-template-columns: 1fr 1fr 4fr;
        margin-bottom: 10px;
      }

      .outcome-chip-wrapper {
        font-weight: bold;
        text-align: center;
      }

      .short-event-description {
        font-size: 0.8em;
        color: black;
        text-decoration: underline;
        cursor: pointer;
        padding: 0.2em;
      }

      .short-event-description-yes:hover {
        background-color: rgba(0, 128, 0, 0.2);
        color: green;
      }

      .short-event-description-no:hover {
        background-color: rgba(255, 0, 0, 0.2);
        color: red;
      }

      .short-event-description-pending:hover {
        background-color: rgba(128, 128, 128, 0.2);
        color: black;
      }

      .short-event-description-yes:active {
        background-color: green;
        color: white;
      }

      .short-event-description-no:active {
        background-color: red;
        color: white;
      }

      .short-event-description-pending:active {
        background-color: black;
        color: white;
      }

      .plot-div {
        padding-left: 1rem;
        padding-right: 1rem;
        width: 550px;
        max-width: 550px;
      }

      .all-plots-wrapper {
        width: 100%;
      }

      .query-box-container {
        display: flex;
        justify-content: space-around;
        width: 100%;
        margin-bottom: 1rem;
      }

      .query-box-item {
        flex: 1;
        margin: 0 0.5rem;
        padding: 0.5rem;
        border: 1px solid #ced4da;
        border-radius: 0.25rem;
        min-width: 150px;
        max-width: 300px;
      }

      .query-box-input {
        width: 100%;
        box-sizing: border-box;
      }

      @media (max-width: 768px) {
        .plots-container {
          display: flex;
          flex-direction: column;
          align-items: flex-start;
        }

        .short-event-description {
          width: 100%;
          padding-right: 0;
          margin-bottom: 0.5rem;
        }

        .plot-div {
          width: 100%;
          min-width: 0;
        }

        .query-box-container {
          flex-direction: column;
        }

        .query-box-item {
          margin: 0.5rem 0;
          max-width: none;
        }
      }
    |}]

module Which_events = struct
  module T = struct
    type t =
      | All
      | One of Event.t
    [@@deriving compare, equal, sexp_of, variants]
  end

  include T
  include Comparable.Make_plain (T)
end

module Which_respondents = struct
  module T = struct
    type t =
      | None
      | One of string
    [@@deriving compare, equal, sexp, variants]
  end

  include T
  include Comparable.Make (T)
end

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
    ~selected_item_attr:(return Style.selected_item)
    ~extra_list_container_attr:(return Style.list_container)
    ~extra_input_attr:
      (let%arr set_state = set_state in
       Vdom.Attr.many
         [ Vdom.Attr.placeholder placeholder_text
         ; Style.query_box_input
         ; Vdom.Attr.on_change (fun _event value ->
             if String.is_empty value then set_state default_value else Effect.Ignore)
         ; Vdom.Attr.on_focus (fun event ->
             Js.Opt.iter event##.target (fun target ->
               Js.Opt.iter (Dom_html.CoerceTo.input target) (fun input ->
                 input##select));
             Effect.Ignore)
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
      (which_events : Which_events.t)
      (which_respondents : Which_respondents.t)
  =
  let events_to_plot =
    match which_events with
    | All -> t.events
    | One event -> [ event ]
  in
  let effects =
    List.map events_to_plot ~f:(fun event ->
      let responses = get_responses t (Event.id event) in
      let fill_color, line_color =
        match Event.outcome event with
        | Yes -> "rgba(0, 128, 0, 0.1)", "green"
        | No -> "rgba(255, 0, 0, 0.1)", "red"
        | Pending -> "rgba(128, 128, 128, 0.1)", "gray"
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
          let colors =
            List.map (respondents t) ~f:(fun respondent ->
              if
                match which_respondents with
                | None -> false
                | One selected_respondent -> String.equal respondent selected_respondent
              then "blue"
              else "rgba(128, 128, 128, 0.2)")
            |> Array.of_list
          in
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

let component t graph =
  let which_events, set_which_events = Bonsai.state Which_events.All graph in
  let which_respondents, set_which_respondents =
    Bonsai.state Which_respondents.None graph
  in
  let select_which_events =
    create_query_box
      (module Which_events)
      ~set_state:set_which_events
      ~placeholder_text:"View all events"
      ~default_value:All
      ~items:
        (Which_events.All :: List.map (events t) ~f:Which_events.one
         |> Which_events.Set.of_list
         |> Which_events.Map.of_key_set ~f:(function
           | All -> "View all events"
           | One event -> Event.short event)
         |> return)
      graph
  in
  let select_which_respondents =
    create_query_box
      (module Which_respondents)
      ~set_state:set_which_respondents
      ~placeholder_text:"No respondent highlighted"
      ~default_value:None
      ~items:
        (Which_respondents.None :: List.map (respondents t) ~f:Which_respondents.one
         |> Which_respondents.Set.of_list
         |> Which_respondents.Map.of_key_set ~f:(function
           | None -> "No respondent highlighted"
           | One respondent -> respondent)
         |> return)
      graph
  in
  let () =
    Bonsai.Edge.on_change
      ~equal:[%equal: Which_events.t * Which_respondents.t]
      (let%arr which_events = which_events
       and which_respondents = which_respondents in
       which_events, which_respondents)
      ~callback:
        (let%arr () = return () in
         fun (which_events, which_respondents) ->
           render_plots t which_events which_respondents)
      graph
  in
  let open Vdom in
  let plots =
    let%arr which_events = which_events
    and set_which_events = set_which_events
    and select_which_events = select_which_events in
    let render_outcome_chip event =
      let outcome = Event.outcome event in
      let outcome_style =
        match outcome with
        | Yes -> Style.outcome_chip_yes
        | No -> Style.outcome_chip_no
        | Pending -> Style.outcome_chip_pending
      in
      Node.span
        ~attrs:[ Attr.class_ "outcome-chip"; Style.outcome_chip; outcome_style ]
        [ Node.text (outcome |> Outcome.to_string) ]
    in
    match which_events with
    | One event ->
      [ Node.div
          ~attrs:[]
          [ Node.div ~attrs:[ Style.outcome_chip_wrapper ] [ render_outcome_chip event ]
          ; Node.div [ Node.text (Event.precise event) ]
          ; Node.div ~attrs:[ Attr.id "plot-single" ] []
          ]
      ]
    | All ->
      List.map t.events ~f:(fun event ->
        let outcome_hover_style =
          match Event.outcome event with
          | Yes -> Style.short_event_description_yes
          | No -> Style.short_event_description_no
          | Pending -> Style.short_event_description_pending
        in
        Node.div
          ~attrs:[ Style.plots_container ]
          [ Node.div ~attrs:[ Style.outcome_chip_wrapper ] [ render_outcome_chip event ]
          ; Node.a
              ~attrs:
                [ Style.short_event_description
                ; outcome_hover_style
                ; Attr.href "#"
                ; Attr.on_click (fun dom_event ->
                    Dom.preventDefault dom_event;
                    Effect.all_unit
                      [ set_which_events (One event)
                      ; Query_box.set_query select_which_events (Event.short event)
                      ])
                ]
              [ Node.text (Event.short event) ]
          ; Node.div
              ~attrs:
                [ Attr.id [%string "plot-%{Event.id event#Event_id}"]; Style.plot_div ]
              []
          ])
  in
  let%arr plots = plots
  and select_which_events = select_which_events
  and select_which_respondents = select_which_respondents in
  Node.div
    [ Node.div
        ~attrs:[ Style.query_box_container ]
        [ Query_box.view select_which_events; Query_box.view select_which_respondents ]
    ; Node.div plots ~attrs:[ Style.all_plots_wrapper ]
    ]
;;
