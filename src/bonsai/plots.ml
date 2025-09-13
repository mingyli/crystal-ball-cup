open! Core
open Crystal
open Js_of_ocaml
module Bonsai = Bonsai.Cont
open Bonsai_web.Cont
open Bonsai.Let_syntax
module Query_box = Bonsai_web_ui_query_box
module Form = Bonsai_web_ui_form.With_manual_view
module E = Form.Elements

module Outcome = struct
  include Outcome

  let color = function
    | Yes -> Colors.blue
    | No -> Colors.orange
    | Pending -> Colors.gray
  ;;

  let accent_color = function
    | Yes -> Colors.light_blue
    | No -> Colors.light_orange
    | Pending -> Colors.light_gray
  ;;
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

      .outcome-chip-wrapper {
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
        min-width: 150px;
        max-width: 300px;
        justify-content: center;
        align-items: center;
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
      (which_events : Which_events.t)
      (which_respondents : Which_respondents.t)
      (selected_outcomes : Outcome.Set.t)
  =
  let events_to_plot =
    let all_events =
      List.filter t.events ~f:(fun event ->
        Set.mem selected_outcomes (Event.outcome event))
    in
    match which_events with
    | All -> all_events
    | One event ->
      if Set.mem selected_outcomes (Event.outcome event) then [ event ] else []
  in
  let effects =
    List.map events_to_plot ~f:(fun event ->
      let responses = get_responses t (Event.id event) in
      let fill_color, line_color =
        match Event.outcome event with
        | Yes -> Colors.very_light_blue, Colors.blue
        | No -> Colors.very_light_orange, Colors.orange
        | Pending -> Colors.very_light_gray, Colors.gray
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

let component t graph =
  let t = Bonsai.return t in
  let which_events, set_which_events = Bonsai.state Which_events.All graph in
  let which_respondents, set_which_respondents =
    Bonsai.state Which_respondents.None graph
  in
  let outcomes_checkboxes_form =
    E.Checkbox.set
      (module Outcome)
      ~layout:`Horizontal
      ~to_string:Outcome.to_string
      ~style:(Bonsai.return E.Selectable_style.Button_like)
      ~extra_checkbox_attrs:
        (Bonsai.return (fun ~checked ->
           [ {%css|
             font-size: 0.8em;
             padding: 0.2em 0.4em;
             margin: 0.4em;
           |}
           ; (if checked
              then
                {%css|
              background-color: %{Colors.burgundy};
              color: %{Colors.white};
              border: solid 1px %{Colors.transparent};
              |}
              else
                {%css|
              background-color: %{Colors.transparent};
              color: %{Colors.black};
              border: solid 1px %{Colors.burgundy};
              |})
           ]))
      ~extra_container_attrs:(Bonsai.return [ Style.query_box_item ])
      (Bonsai.return Outcome.all)
      graph
  in
  let outcomes_checkboxes_form_with_default =
    Form.Dynamic.with_default
      (Bonsai.return (Outcome.Set.of_list Outcome.all))
      outcomes_checkboxes_form
      graph
  in
  let selected_outcomes =
    let%arr form = outcomes_checkboxes_form_with_default in
    Form.value_or_default form ~default:Outcome.Set.empty
  in
  let outcomes_checkboxes_vdom =
    let%arr form = outcomes_checkboxes_form_with_default in
    form.view
  in
  let select_which_events =
    create_query_box
      (module Which_events)
      ~set_state:set_which_events
      ~placeholder_text:"View all events"
      ~default_value:All
      ~items:
        (let%map t = t in
         Which_events.All :: List.map (events t) ~f:Which_events.one
         |> Which_events.Set.of_list
         |> Which_events.Map.of_key_set ~f:(function
           | All -> "View all events"
           | One event -> Event.short event))
      graph
  in
  let select_which_respondents =
    create_query_box
      (module Which_respondents)
      ~set_state:set_which_respondents
      ~placeholder_text:"No respondent highlighted"
      ~default_value:None
      ~items:
        (let%map t = t in
         Which_respondents.None :: List.map (respondents t) ~f:Which_respondents.one
         |> Which_respondents.Set.of_list
         |> Which_respondents.Map.of_key_set ~f:(function
           | None -> "No respondent highlighted"
           | One respondent -> respondent))
      graph
  in
  let () =
    Bonsai.Edge.on_change
      ~equal:[%equal: Which_events.t * Which_respondents.t * Outcome.Set.t]
      (let%arr which_events = which_events
       and which_respondents = which_respondents
       and selected_outcomes = selected_outcomes in
       which_events, which_respondents, selected_outcomes)
      ~callback:
        (let%arr t = t in
         fun (which_events, which_respondents, selected_outcomes) ->
           render_plots t which_events which_respondents selected_outcomes)
      graph
  in
  let open Vdom in
  let plots =
    let%arr which_events = which_events
    and set_which_events = set_which_events
    and select_which_events = select_which_events
    and selected_outcomes = selected_outcomes
    and t = t in
    let events_in_view =
      List.filter (events t) ~f:(fun event ->
        Set.mem selected_outcomes (Event.outcome event))
    in
    let render_outcome_chip event =
      let outcome = Event.outcome event in
      let outcome_style =
        {%css| background-color: %{Outcome.accent_color outcome}; color: %{Outcome.color outcome}; |}
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
          ; outcome_style
          ]
        [ Node.text (outcome |> Outcome.to_string) ]
    in
    match which_events with
    | One event ->
      if Set.mem selected_outcomes (Event.outcome event)
      then
        [ Node.div
            ~attrs:[]
            [ Node.div ~attrs:[ Style.outcome_chip_wrapper ] [ render_outcome_chip event ]
            ; Node.div [ Node.text (Event.precise event) ]
            ; Node.div ~attrs:[ Attr.id "plot-single" ] []
            ]
        ]
      else []
    | All ->
      List.map events_in_view ~f:(fun event ->
        let outcome = Event.outcome event in
        let outcome_hover_style =
          {%css|
            &:hover {
              background-color: %{Outcome.accent_color outcome};
              color: %{Outcome.color outcome};
            }

            &:active {
              background-color: %{Outcome.color outcome};
              color: %{Colors.white};
            }
            |}
        in
        Node.div
          ~attrs:[ Style.plots_container ]
          [ Node.div ~attrs:[ Style.outcome_chip_wrapper ] [ render_outcome_chip event ]
          ; Node.a
              ~attrs:
                [ {%css|
                    font-size: 0.8em;
                    color: %{Colors.black};
                    text-decoration: underline;
                    cursor: pointer;
                    padding: 0.2em;
                  |}
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
  and select_which_respondents = select_which_respondents
  and outcomes_checkboxes_vdom = outcomes_checkboxes_vdom in
  Node.div
    [ Node.div
        ~attrs:[ Style.query_box_container ]
        [ outcomes_checkboxes_vdom
        ; Query_box.view select_which_events
        ; Query_box.view select_which_respondents
        ]
    ; Node.div plots ~attrs:[ {%css| width: 100%; |} ]
    ]
;;
