open! Core
module Bonsai = Bonsai.Cont
open Bonsai.Let_syntax

let component graph =
  let data : Dygraph.Data.t =
    Array.init 10 ~f:(fun i ->
      let x = float i in
      [| x; x ** 2.; x ** 3. |])
    |> Dygraph.Data.create
  in
  let x_label = "x" in
  let options =
    let cubed_series_options =
      Dygraph.Options.Series_options.create () ~axis:`y2 ~color:(`Name "purple")
    in
    let squared_series_otions =
      Dygraph.Options.Series_options.create () ~axis:`y1 ~color:(`Hex "#70ba70")
    in
    let axes =
      let y2_axis_options =
        Dygraph.Options.Axis_options.create () ~independentTicks:true
      in
      Dygraph.Options.Axes.create () ~y2:y2_axis_options
    in
    let series =
      Dygraph.Options.Series.create
        [ "x^2", squared_series_otions; "x^3", cubed_series_options ]
    in
    Dygraph.Options.create
      ()
      ~drawPoints:true
      ~strokeWidth:0.
      ~series
      ~title:"Simple example"
      ~xlabel:x_label
      ~ylabel:"x^2"
      ~y2label:"x^3"
      ~axes
  in
  let dygraph =
    Dygraph.With_bonsai.create
      ()
      ~key:(return "graph")
      ~x_label:(return "x")
      ~per_series_info:
        (return ([ "x^2"; "x^3" ] |> Dygraph.Per_series_info.create_all_visible))
      ~options:(return options)
      ~data:(return data)
      graph
  in
  let%arr { graph_view; _ } = dygraph in
  graph_view
;;
