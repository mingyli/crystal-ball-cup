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
      .container {
        font-family: sans-serif;
        margin: 2em;
      }

      .controls {
        margin-bottom: 1em;
        display: flex;
        gap: 1em;
        align-items: center;
      }

      .predictions-table {
        border-collapse: collapse;
        width: 100%;
        margin-top: 1em;
      }

      .predictions-table th,
      .predictions-table td {
        border: 1px solid #ddd;
        padding: 8px;
      }

      .predictions-table th {
        background-color: #f2f2f2;
        text-align: left;
      }

      .confidence-plot {
        margin-top: 2em;
      }

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
    ~selected_item_attr:(return Style.selected_item)
    ~extra_list_container_attr:(return Style.list_container)
    ~extra_input_attr:
      (let%arr set_state = set_state in
       Vdom.Attr.many
         [ Vdom.Attr.placeholder placeholder_text
         ; Style.query_box_input
         ; Vdom.Attr.on_change (fun _event value ->
             if String.is_empty value then set_state default_value else Effect.Ignore)
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

module Respondent = struct
  module T = struct
    type t =
      | None
      | Some of string
    [@@deriving compare, equal, sexp]
  end

  include T
  include Comparable.Make (T)
end

let component ~collection ~responses graph =
  let respondents = Map.keys responses in
  let selected_respondent, set_selected_respondent = Bonsai.state Respondent.None graph in
  let confidence, set_confidence = Bonsai.state 1.0 graph in
  let respondent_query_box =
    create_query_box
      (module Respondent)
      ~set_state:set_selected_respondent
      ~placeholder_text:"Select User"
      ~default_value:None
      ~items:
        (Respondent.None :: List.map respondents ~f:(fun x -> Respondent.Some x)
         |> Respondent.Set.of_list
         |> Respondent.Map.of_key_set ~f:(function
           | None -> "Select User"
           | Some respondent -> respondent)
         |> return)
      graph
  in
  let%arr selected_respondent = selected_respondent
  and confidence = confidence
  and set_confidence = set_confidence
  and respondent_query_box = respondent_query_box in
  let open Vdom in
  let table_body, mean_score =
    match selected_respondent with
    | None -> [], "N/A"
    | Some respondent ->
      let original_responses = Map.find_exn responses respondent in
      let adjusted_responses =
        Responses.scale_by_confidence original_responses ~confidence
      in
      let scores = Scores.create collection adjusted_responses in
      let scored_events =
        Map.filter (Scores.event_scores scores) ~f:(fun s -> not (Float.is_nan s))
      in
      let mean_score =
        if Map.is_empty scored_events
        then "N/A"
        else (
          let total_score = List.sum (module Float) (Map.data scored_events) ~f:Fn.id in
          let count = Float.of_int (Map.length scored_events) in
          sprintf "%.3f" (total_score /. count))
      in
      let table_rows =
        List.map (Collection.all collection) ~f:(fun event ->
          let event_id = Event.id event in
          let original_pred =
            Map.find (Responses.probabilities original_responses) event_id
          in
          let adjusted_pred =
            Map.find (Responses.probabilities adjusted_responses) event_id
          in
          Node.tr
            [ Node.td [ Node.text (Event.short event) ]
            ; Node.td
                [ Node.text
                    (Option.value_map original_pred ~default:"-" ~f:(sprintf "%.3f"))
                ]
            ; Node.td
                [ Node.text
                    (Option.value_map adjusted_pred ~default:"-" ~f:(sprintf "%.3f"))
                ]
            ])
      in
      table_rows, mean_score
  in
  Node.div
    ~attrs:[ Style.container ]
    [ Node.h1 [ Node.text "Crystal Ball Cup Analysis" ]
    ; Node.div
        ~attrs:[ Style.controls ]
        [ Node.label ~attrs:[ Attr.for_ "user-select" ] [ Node.text "Select User:" ]
        ; Query_box.view respondent_query_box
        ; Node.label ~attrs:[ Attr.for_ "confidence-slider" ] [ Node.text "Confidence:" ]
        ; Node.input
            ~attrs:
              [ Attr.type_ "range"
              ; Attr.id "confidence-slider"
              ; Attr.min 0.
              ; Attr.max 10.
              ; Attr.value (Float.to_string confidence)
              ; Attr.create "step" "0.1"
              ; Attr.on_input (fun _ v -> set_confidence (Float.of_string v))
              ]
            ()
        ; Node.span [ Node.text (sprintf "%.1f" confidence) ]
        ]
    ; Node.h2 [ Node.text "Predictions" ]
    ; Node.table
        ~attrs:[ Style.predictions_table ]
        [ Node.thead
            [ Node.tr
                [ Node.th [ Node.text "Event" ]
                ; Node.th [ Node.text "Original Prediction" ]
                ; Node.th [ Node.text "Confidence-Adjusted Prediction" ]
                ]
            ]
        ; Node.tbody table_body
        ]
    ; Node.h2 [ Node.text ("Mean Score: " ^ mean_score) ]
    ; Node.div ~attrs:[ Style.confidence_plot; Attr.id "confidence-plot" ] []
    ]
;;
