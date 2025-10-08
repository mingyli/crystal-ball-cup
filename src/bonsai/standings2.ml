open! Core
open Crystal
module Bonsai = Bonsai.Cont
open Bonsai_web.Cont
open Bonsai.Let_syntax
open Dygraph.With_bonsai

type t =
  { events : Event.t list
  ; scores : (string, Scores.t) List.Assoc.t
  }
[@@deriving fields]

let create events scores =
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

let respondents t = List.map t.scores ~f:fst

let cumulative_scores ~events ~scores =
  List.folding_map events ~init:0. ~f:(fun sum event ->
    let event_id = Event.id event in
    let event_score = Scores.event_score scores event_id in
    let new_cumulative_score =
      if Float.is_nan event_score then sum else sum +. event_score
    in
    new_cumulative_score, new_cumulative_score)
;;

let cumulative_scores t =
  List.Assoc.map t.scores ~f:(fun scores -> cumulative_scores ~events:t.events ~scores)
;;

let min_finite_score t =
  let cumulative_scores = cumulative_scores t in
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
  let cumulative_scores = cumulative_scores t in
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

let component t graph =
  let cumulative_scores = cumulative_scores t in
  let respondents = respondents t in
  let min_finite_score = min_finite_score t in
  let max_finite_score = max_finite_score t in
  let min_total_score = min_total_score t in
  let max_total_score = max_total_score t in
  let total_scores = total_scores t in
  let all_cumulative_series =
    List.map respondents ~f:(fun respondent ->
      List.Assoc.find_exn cumulative_scores respondent ~equal:[%equal: string])
  in
  let dygraph_data =
    t.events
    |> List.to_array
    |> Array.mapi ~f:(fun i event ->
      let event_id = Event.id event in
      let event_id_as_float = event_id |> Event_id.to_int |> Int.to_float in
      let row_data =
        List.map all_cumulative_series ~f:(fun series -> List.nth_exn series i)
      in
      Array.of_list (event_id_as_float :: row_data))
    |> Dygraph.Data.create
  in
  let options =
    let series_options =
      List.map total_scores ~f:(fun (id, score) ->
        let color =
          let r_zero, g_zero, b_zero = 128., 128., 128. in
          let r_pos, g_pos, b_pos = 0., 192., 64. in
          let r_neg, g_neg, b_neg = 192., 0., 64. in
          let red_val, green_val, blue_val =
            if Float.(score > 0.0)
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
            Printf.sprintf
              "#%02x%02x%02x"
              (clamp_byte red_val)
              (clamp_byte green_val)
              (clamp_byte blue_val)
          in
          `Hex hex_color
        in
        ( id
        , Dygraph.Options.Series_options.create
            ()
            ~strokeWidth:0.75
            ~drawPoints:false
            ~color ))
    in
    let series = Dygraph.Options.Series.create series_options in
    let y_axis_range =
      let upper_bound = max_finite_score *. 1.1 in
      let lower_bound = min_finite_score *. 1.1 in
      Dygraph.Range.Spec.Specified { Dygraph.Range.low = lower_bound; high = upper_bound }
    in
    let axes =
      Dygraph.Options.Axes.create
        ()
        ~x:(Dygraph.Options.Axis_options.create () ~drawGrid:false)
        ~y:
          (Dygraph.Options.Axis_options.create
             ()
             ~valueRange:y_axis_range
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
      ?legendFormatter:None
      ~drawPoints:false
      ~strokeWidth:1.0
      ~strokeBorderWidth:1.0
      ~series
      ~axes
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
      ~x_label:(return "Event ID")
      ~per_series_info:(return per_series_info)
      ~options:(return options)
      ~data:(return dygraph_data)
      ~custom_legend:
        (let%sub model, view, inject =
           Dygraph.Default_legend.create
             ~x_label:(Bonsai.return "Event")
             ~per_series_info:(return per_series_info)
             graph
         in
         let model =
           let%map model = model in
           { Legend_model.visibility =
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
  let%arr { graph_view; _ } = dygraph in
  graph_view
;;
