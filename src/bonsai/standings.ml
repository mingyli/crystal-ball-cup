open! Core
open Crystal
module Bonsai = Bonsai.Cont
open Bonsai_web.Cont
open Bonsai.Let_syntax
module Form = Bonsai_web_ui_form.With_manual_view

module Sort_by = struct
  type t =
    | Date
    | Event_id
  [@@deriving compare, enumerate, equal, sexp_of]

  let to_string = function
    | Date -> "Date"
    | Event_id -> "Event ID"
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

let respondents t = List.map t.scores ~f:fst

let cumulative_scores_by_id ~events ~scores =
  List.folding_map events ~init:0. ~f:(fun sum event ->
    let event_id = Event.id event in
    let event_score = Scores.event_score scores event_id in
    let new_cumulative_score =
      if Float.is_nan event_score then sum else sum +. event_score
    in
    new_cumulative_score, new_cumulative_score)
;;

let cumulative_scores_by_id t =
  List.Assoc.map t.scores ~f:(fun scores ->
    cumulative_scores_by_id ~events:t.events ~scores)
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

let cumulative_scores_by_date t =
  List.Assoc.map t.scores ~f:(fun scores ->
    cumulative_scores_by_date ~events:t.events ~scores)
;;

let cumulative_scores t =
  match%arr t.sort_by with
  | Date -> cumulative_scores_by_date t
  | Event_id -> cumulative_scores_by_id t
;;

let min_finite_score t =
  let%arr cumulative_scores = cumulative_scores t in
  let min_finite_score =
    cumulative_scores
    |> List.map ~f:snd
    |> List.concat
    |> List.filter ~f:Float.is_finite
    |> List.min_elt ~compare:Float.compare
    |> Option.value_exn
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
    |> Option.value_exn
  in
  max_score
;;

let total_scores t = List.Assoc.map t.scores ~f:Scores.total

let min_total_score t =
  total_scores t
  |> List.map ~f:snd
  |> List.filter ~f:Float.is_finite
  |> List.min_elt ~compare:Float.compare
  |> Option.value_exn
;;

let max_total_score t =
  total_scores t
  |> List.map ~f:snd
  |> List.filter ~f:Float.is_finite
  |> List.max_elt ~compare:Float.compare
  |> Option.value_exn
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
  let respondents = respondents t in
  let min_total_score = min_total_score t in
  let max_total_score = max_total_score t in
  let total_scores = total_scores t in
  let cumulative_scores = cumulative_scores t in
  let min_finite_score = min_finite_score t in
  let max_finite_score = max_finite_score t in
  let all_cumulative_series cumulative_scores =
    List.map respondents ~f:(fun respondent ->
      List.Assoc.find_exn cumulative_scores respondent ~equal:[%equal: string])
  in
  let dygraph_data (sort_by : Sort_by.t) cumulative_scores =
    match sort_by with
    | Event_id ->
      t.events
      |> List.to_array
      |> Array.mapi ~f:(fun i event ->
        let event_id = Event.id event in
        let event_id_as_float = event_id |> Event_id.to_int |> Int.to_float in
        let row_data =
          List.map (all_cumulative_series cumulative_scores) ~f:(fun series ->
            List.nth_exn series i)
        in
        Array.of_list (event_id_as_float :: row_data))
      |> Dygraph.Data.create
    | Date ->
      t.events
      |> List.sort ~compare:(fun event event' ->
        [%compare: Date.t option] (Event.date event) (Event.date event'))
      |> List.to_array
      |> Array.filter_mapi ~f:(fun i event ->
        let%map.Option date = Event.date event in
        let row_data =
          List.map (all_cumulative_series cumulative_scores) ~f:(fun series ->
            List.nth_exn series i)
        in
        date, Array.of_list row_data)
      |> Dygraph.Data.create_date ~zone:(Timezone.of_string "America/New_York")
  in
  let options (sort_by : Sort_by.t) min_finite_score max_finite_score =
    let series_options =
      List.map total_scores ~f:(fun (respondent, score) ->
        let color =
          let r_zero, g_zero, b_zero = 128., 128., 128. in
          let r_pos, g_pos, b_pos = 0., 192., 64. in
          let r_neg, g_neg, b_neg = 192., 0., 64. in
          let red_val, green_val, blue_val =
            if Float.equal score Float.neg_infinity
            then r_neg, g_neg, b_neg
            else if Float.equal score Float.infinity
            then r_pos, g_pos, b_pos
            else if Float.(score > 0.0)
            then (
              let ratio = score /. max_total_score in
              let r = r_zero +. ((r_pos -. r_zero) *. ratio) in
              let g = g_zero +. ((g_pos -. g_zero) *. ratio) in
              let b = b_zero +. ((b_pos -. b_zero) *. ratio) in
              r, g, b)
            else if Float.(score < 0.0)
            then (
              let ratio = score /. min_total_score in
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
          let hex_color =
            [%string
              "rgb(%{clamp_byte red_val#Int}, %{clamp_byte green_val#Int}, %{clamp_byte \
               blue_val#Int})"]
          in
          `Hex hex_color
        in
        respondent, Dygraph.Options.Series_options.create () ~drawPoints:false ~color)
    in
    let series = Dygraph.Options.Series.create series_options in
    let axes =
      Dygraph.Options.Axes.create
        ()
        ~x:
          (Dygraph.Options.Axis_options.create
             ()
             ~drawGrid:false
             ~pixelsPerLabel:
               (match sort_by with
                | Event_id -> 20
                | Date -> 100))
        ~y:
          (Dygraph.Options.Axis_options.create
             ()
             ~valueRange:
               (let upper_bound = max_finite_score *. 1.1 in
                let lower_bound = min_finite_score *. 1.1 in
                Specified { low = lower_bound; high = upper_bound })
             ~includeZero:true
             ~drawGrid:false)
    in
    Dygraph.Options.create
      ()
      ~xlabel:"Event"
      ~ylabel:"Cumulative Score"
      ~width:600
      ~height:600
      ~labelsSeparateLines:false
      ~labelsDiv_string:"my-custom-legend"
      ~legend:`never
      ?dateWindow:
        (match sort_by with
         | Event_id -> Some Dygraph.Range.{ low = 0.5; high = 20.5 }
         | Date ->
           let low =
             Time_ns.of_date_ofday
               ~zone:(Timezone.of_string "America/New_York")
               (Date.of_string "2025-08-20")
               Time_ns.Ofday.start_of_day
           in
           let high =
             Time_ns.of_date_ofday
               ~zone:(Timezone.of_string "America/New_York")
               (Date.of_string "2025-12-31")
               Time_ns.Ofday.approximate_end_of_day
           in
           Some
             Dygraph.Range.
               { low = low |> Time_ns.to_span_since_epoch |> Time_ns.Span.to_ms
               ; high = high |> Time_ns.to_span_since_epoch |> Time_ns.Span.to_ms
               })
      ?legendFormatter:None
      ~drawPoints:false
      ~strokeWidth:1.0
      ~strokeBorderWidth:1.0
      ~series
      ~axes
      ~xRangePad:10.
      ~includeZero:true
      ~highlightSeriesOpts:
        (Dygraph.Options.Highlight_series_options.create
           ()
           ~strokeWidth:3.0
           ~strokeBorderWidth:1.0
           ~highlightCircleSize:5)
      ~pointClickCallback:(fun ~evt:_ ~point:_ -> ())
      ~highlightCallback:(fun ~evt:_ ~x:_ ~points:_ ~row:_ ~seriesName:_ -> ())
      ~pointSize:2
  in
  let per_series_info = Dygraph.Per_series_info.create_all_visible respondents in
  let dygraph =
    Dygraph.With_bonsai.create
      ()
      ~key:(return "standings-dygraph")
      ~x_label:
        (let%arr sort_by = t.sort_by in
         Sort_by.to_string sort_by)
      ~per_series_info:(return per_series_info)
      ~options:
        (let%arr sort_by = t.sort_by
         and min_finite_score = min_finite_score
         and max_finite_score = max_finite_score in
         options sort_by min_finite_score max_finite_score)
      ~data:
        (let%arr sort_by = t.sort_by
         and cumulative_scores = cumulative_scores in
         dygraph_data sort_by cumulative_scores)
      ~custom_legend:
        (let%sub model, view, inject =
           Dygraph.Default_legend.create
             ~x_label:
               (let%arr sort_by = t.sort_by in
                Sort_by.to_string sort_by)
             ~per_series_info:(return per_series_info)
             graph
         in
         let model =
           let%map model = model in
           { Dygraph.With_bonsai.Legend_model.visibility =
               List.map model.series ~f:Dygraph.Default_legend.Model.Series.is_visible
           }
         in
         let inject =
           let%map inject = inject in
           fun data -> inject (From_graph data)
         in
         let%arr model = model
         and view = view
         and inject = inject in
         model, view, inject)
      ~extra_attr:(return {%css|font-size: 0.8rem;|})
      graph
  in
  let%arr { graph_view; _ } = dygraph
  and { view; value = _; set = _ } = radio in
  Vdom.Node.div [ graph_view; view ]
;;
