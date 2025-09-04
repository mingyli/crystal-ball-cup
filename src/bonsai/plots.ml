open! Core
open Crystal
open Js_of_ocaml
open Bonsai_web
open Bonsai.Let_syntax

module Which_events = struct
  type t =
    | All
    | One of Event.t
  [@@deriving equal, variants]
end

module Which_respondents = struct
  type t =
    | None
    | One of string
  [@@deriving equal, variants]
end

let create_dropdown
      (type a)
      ~(on_change : a -> unit Vdom.Effect.t)
      ~(items : a list)
      ~(selected : a)
      ~(item_to_string : a -> string)
      ~(equal : a -> a -> bool)
  =
  let open Vdom in
  Node.select
    ~attrs:
      [ Attr.on_change (fun _event value ->
          let selection =
            List.find_exn items ~f:(fun o -> String.equal (item_to_string o) value)
          in
          on_change selection)
      ; {%css|
            padding: 0.5rem;
            border: 1px solid #ced4da;
            border-radius: 0.25rem;
            flex: 1;
            min-width: 150px;
            max-width: 300px;
            |}
      ]
    (List.map items ~f:(fun item ->
       Node.option
         ~attrs:
           [ Attr.value (item_to_string item)
           ; Attr.bool_property "selected" (equal item selected)
           ]
         [ Node.text (item_to_string item) ]))
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

let component t =
  let%sub which_events, set_which_events = Bonsai.state Which_events.All in
  let%sub which_respondents, set_which_respondents =
    Bonsai.state Which_respondents.None
  in
  let%sub () =
    Bonsai.Edge.on_change
      ~equal:[%equal: Which_events.t * Which_respondents.t]
      (Value.both which_events which_respondents)
      ~callback:
        (let%map () = Value.return () in
         fun (which_events, which_respondents) ->
           render_plots t which_events which_respondents)
  in
  let%arr () = Value.return ()
  and which_events = which_events
  and set_which_events = set_which_events
  and which_respondents = which_respondents
  and set_which_respondents = set_which_respondents in
  let open Vdom in
  let plots =
    match which_events with
    | One event ->
      [ Node.div
          ~attrs:[]
          [ Node.span
              ~attrs:
                [ Attr.class_ "outcome-chip"
                ; {%css|
                          display: inline-block;
                          padding: 0.2em 0.6em;
                          border-radius: 1em;
                          font-size: 0.8em;
                          text-align: center;
                          white-space: nowrap;
                          vertical-align: middle;
                          line-height: 1;
                          |}
                ; (match Event.outcome event with
                   | Yes -> {%css|background-color: rgba(0, 128, 0, 0.2); color: green;|}
                   | No -> {%css|background-color: rgba(255, 0, 0, 0.2); color: red;|}
                   | Pending ->
                     {%css|background-color: rgba(128, 128, 128, 0.2); color: rgba(128, 128, 128, 0.8);|})
                ]
              [ Node.text (event |> Event.outcome |> Outcome.to_string) ]
          ; Node.div [ Node.text (Event.precise event) ]
          ; Node.div ~attrs:[ Attr.id "plot-single" ] []
          ]
      ]
    | All ->
      List.map t.events ~f:(fun event ->
        Node.div
          ~attrs:
            [ {%css|
            display: flex;
            align-items: center;
            margin-bottom: 1rem;
            |}
            ]
          [ Node.div
              ~attrs:
                [ {%css|
                width: 80px;
                font-weight: bold;
                text-align: center;
                padding-right: 1rem;
                |}
                ]
              [ Node.span
                  ~attrs:
                    [ Attr.class_ "outcome-chip"
                    ; {%css|
                    display: inline-block;
                    padding: 0.2em 0.6em;
                    border-radius: 1em;
                    font-size: 0.8em;
                    text-align: center;
                    white-space: nowrap;
                    vertical-align: middle;
                    line-height: 1;
                    |}
                    ; (match Event.outcome event with
                       | Yes ->
                         {%css|background-color: rgba(0, 128, 0, 0.2); color: green;|}
                       | No -> {%css|background-color: rgba(255, 0, 0, 0.2); color: red;|}
                       | Pending ->
                         {%css|background-color: rgba(128, 128, 128, 0.2); color: rgba(128, 128, 128, 0.8);|})
                    ]
                  [ Node.text (event |> Event.outcome |> Outcome.to_string) ]
              ]
          ; Node.div
              ~attrs:
                [ {%css|
                width: 150px;
                padding-right: 1rem;
                |}
                ]
              [ Node.text (Event.short event) ]
          ; Node.div
              ~attrs:
                [ Attr.id [%string "plot-%{Event.id event#Event_id}"]
                ; {%css|
                width: calc(100% - 230px);
                |}
                ]
              []
          ])
  in
  Node.div
    [ create_dropdown
        ~on_change:set_which_events
        ~items:(Which_events.All :: List.map t.events ~f:Which_events.one)
        ~selected:which_events
        ~item_to_string:(function
          | All -> "View all events"
          | One event -> Event.short event)
        ~equal:[%equal: Which_events.t]
    ; create_dropdown
        ~on_change:set_which_respondents
        ~items:
          (Which_respondents.None :: List.map (respondents t) ~f:Which_respondents.one)
        ~selected:which_respondents
        ~item_to_string:(function
          | None -> "No respondents highlighted"
          | One respondent -> respondent)
        ~equal:[%equal: Which_respondents.t]
    ; Node.div plots ~attrs:[ {%css|width: 100%|} ]
    ]
;;
