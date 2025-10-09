open! Core
module Bonsai = Bonsai.Cont
open Bonsai.Let_syntax
open Bonsai_web.Cont
open Crystal

let render_plot div_id plotly_data layout =
  Effect.of_sync_fun
    (fun () ->
       Crystal_plotly.Plotly.react
         (Js_of_ocaml.Dom_html.getElementById_exn div_id)
         plotly_data
         layout
         { display_mode_bar = false })
    ()
;;

let confidence_scaling =
  let num_samples = 500 in
  let min_exponent_val = -18.0 in
  (* Log of ~1e-8 *)
  let max_exponent_val = 5.0 in
  (* Log of ~148.4 *)
  let step = (max_exponent_val -. min_exponent_val) /. Float.of_int (num_samples - 1) in
  Array.init num_samples ~f:(fun i ->
    let exponent = min_exponent_val +. (Float.of_int i *. step) in
    Float.exp exponent)
;;

let go collection responses =
  let plots =
    Map.data responses
    |> List.map ~f:(fun responses ->
      let scores =
        Array.map confidence_scaling ~f:(fun confidence ->
          let scaled_responses = Responses.scale_by_confidence responses ~confidence in
          let scores = Scores.create collection scaled_responses in
          Scores.total scores)
      in
      let line : Crystal_plotly.Data.t =
        Line
          { x =
              Array.map confidence_scaling ~f:(fun confidence ->
                if Float.is_inf confidence
                then 100.
                else if Float.equal confidence 0.
                then 1e-4
                else confidence)
          ; y = scores
          }
      in
      line)
  in
  let layout : Crystal_plotly.Layout.t =
    { title = { text = "" }
    ; yaxis =
        { autorange = None
        ; automargin = None
        ; tickfont = None
        ; fixedrange = true
        ; range = Some [ -1.; 1. ]
        }
    ; xaxis =
        { title = ""
        ; showticklabels = true
        ; zeroline = false
        ; fixedrange = true
        ; range = Some [ Float.log10 0.1; Float.log10 2. ]
        ; autorange = None
        ; tickvals = Some [ 0.; 0.5; 1.; 2.; Float.infinity ]
        ; ticktext = Some [ "0"; "0.5"; "1"; "2"; "∞" ]
        ; type_ = Some "log"
        }
    ; shapes = []
    ; margin = { l = 20; r = 20; t = 20; b = 20 }
    ; height = 700
    ; showlegend = false
    }
  in
  render_plot "confidence-plot" plots layout
;;

let component ~collection ~responses graph =
  let outcomes =
    collection
    |> Collection.all
    |> List.map ~f:Event.resolution
    |> List.map ~f:(function
      | None -> Float.nan
      | Some resolution -> Resolution.to_float resolution)
    |> List.to_array
  in
  let plots = go collection responses in
  let () =
    Bonsai.Edge.lifecycle
      ~on_activate:
        (let%arr () = return () in
         plots)
      graph
  in
  let%arr () = return () in
  let open Vdom in
  Node.div
    [ Node.div
        (outcomes
         |> List.of_array
         |> List.map ~f:(fun outcome -> Node.div [ Node.text (Float.to_string outcome) ])
        )
      (* ; Node.div
        (scores
         |> List.of_array
         |> List.map ~f:(fun score -> Node.div [ Node.text (Float.to_string score) ])) *)
    ; Node.div ~attrs:[ Attr.id "confidence-plot" ] []
    ]
;;
