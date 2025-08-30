open! Core
open Crystal
open Js_of_ocaml
open Bonsai_web
open Bonsai.Let_syntax
(* open Bonsai_web_ui_toggle
open Bonsai_web_ui_multi_select *)

let events collection =
  let node =
    Vdom.Node.div
    @@ List.map (Collection.all collection) ~f:(fun event ->
      Vdom.Node.div
        [ Vdom.Node.h3 [ Vdom.Node.text (Event.short event) ]
        ; Vdom.Node.p [ Vdom.Node.text (Event.precise event) ]
        ])
  in
  Bonsai.const node
;;

let standings _collection scores =
  let data : Crystal_plotly.Data.t =
    let total_scores =
      Map.map scores ~f:Scores.total
      |> Map.to_alist
      |> List.sort ~compare:(fun (_, a) (_, b) -> Float.compare b a)
    in
    let respondents = List.map total_scores ~f:fst in
    let scores = List.map total_scores ~f:snd in
    let text_array =
      List.to_array scores
      |> Array.map ~f:(fun score ->
        if Float.is_inf score && Float.(score > 0.0)
        then "∞"
        else if Float.is_inf score
        then "-∞"
        else if Float.is_nan score
        then "NaN"
        else Float.to_string_hum ~decimals:3 score)
    in
    let color_array =
      List.to_array scores
      |> Array.map ~f:(fun score ->
        if Float.(score >= 0.0) then "rgba(0, 128, 0, 0.1)" else "rgba(255, 0, 0, 0.1)")
    in
    let line_color_array =
      List.to_array scores
      |> Array.map ~f:(fun score -> if Float.(score >= 0.0) then "green" else "red")
    in
    Bar
      { y = Array.of_list respondents
      ; x = Array.of_list scores
      ; type_ = "bar"
      ; orientation = "h"
      ; text = text_array
      ; textposition = "auto"
      ; hoverinfo = "none"
      ; textfont = { size = 10 }
      ; marker = { color = color_array; line = { color = line_color_array; width = 1 } }
      }
  in
  let respondents_length = Map.length scores in
  let layout : Crystal_plotly.Layout.t =
    { title = { text = "Total Score" }
    ; yaxis =
        { autorange = "reversed"
        ; automargin = true
        ; tickfont = { size = 10 }
        ; fixedrange = true
        }
    ; xaxis = { title = ""; showticklabels = false; zeroline = false; fixedrange = true }
    ; shapes =
        [ { type_ = "line"
          ; x0 = 0.0
          ; y0 = -0.5
          ; x1 = 0.0
          ; y1 = Float.of_int respondents_length -. 0.5
          ; line = { color = "black"; width = 1 }
          }
        ]
    ; margin = { l = 200; r = 20; t = 60; b = 40 }
    ; height = (20 * respondents_length) + 80
    }
  in
  let%sub () =
    Bonsai.Edge.lifecycle
      ~on_activate:
        (Bonsai_web.Value.return
           (Ui_effect.of_sync_fun
              (fun () ->
                 let container = Dom_html.getElementById_exn "standings-plot" in
                 Crystal_plotly.Foo.create
                   container
                   [ data ]
                   layout
                   { display_mode_bar = false })
              ()))
      ()
  in
  Bonsai.const
  @@ Vdom.Node.div
       ~attrs:
         [ Vdom.Attr.id "standings-plot"
         ; Vdom.Attr.style (Css_gen.width (`Px 600))
         ; Vdom.Attr.style (Css_gen.height (`Px 400))
         ]
       []
;;
