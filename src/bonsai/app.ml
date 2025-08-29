open! Core
open Crystal
open Js_of_ocaml
open Bonsai_web
open Bonsai.Let_syntax

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

let standings _collection (scores : Scores.t String.Map.t) =
  let open Plotly in
  let total_scores = Map.map scores ~f:Scores.total |> Map.to_alist in
  let () =
    let open Js_of_ocaml in
    Firebug.console##log total_scores
  in
  let respondents = List.map total_scores ~f:fst in
  let scores = List.map total_scores ~f:snd in
  let figure =
    let data =
      [ Data.orientation "h"
      ; Data.text
          (List.to_array scores
           |> Array.map ~f:(fun score ->
             if Float.is_inf score then "-∞" else Float.to_string_hum ~decimals:3 score))
      ; Data.x (List.to_array scores)
      ; Data.data
          [ "y", Value (Value.array String (List.to_array respondents))
          ; "textposition", Value (Value.string "auto")
          ; "hoverinfo", Value (Value.string "none")
            (* ; ( "textfont"
            , {|{"size":10}|}
              |> Ezjsonm.from_string
              |> Ezjsonm.unwrap
              |> Value.of_json
              |> Option.value_exn ) *)
          ]
        (* ; {|{"textfont":{"size":10}}|}
        |> Ezjsonm.from_string
        |> Ezjsonm.unwrap
        |> Data.of_json
        |> Option.value_exn *)
        (* ; Data.of_json
          (Ezjsonm.from_string
             {|[{"y":["ming","obama"],"textposition":"auto","hoverinfo":"none","type":"bar"}]|}
           |> Ezjsonm.unwrap)
        |> Option.value_exn *)
        (* ; Data.of_json (Ezjsonm.from_string {|[{"type":"bar"}]|} |> Ezjsonm.unwrap)
        |> Option.value_exn *)
      ]
    in
    let () =
      let data =
        Data.data
          [ "y", Value (Value.array String (List.to_array respondents))
          ; "textposition", Value (Value.string "auto")
          ; "hoverinfo", Value (Value.string "none")
          ; "type", Value (Value.string "bar")
          ]
      in
      let data' =
        Data.of_json
          (Ezjsonm.from_string
             {|[{"y":["ming","obama"],"textposition":"auto","hoverinfo":"none","type":"bar"}]|}
           |> Ezjsonm.unwrap)
        |> Option.value_exn
      in
      Js_of_ocaml.Firebug.console##log
        (Data.to_json data |> Ezjsonm.wrap |> Ezjsonm.to_string);
      Js_of_ocaml.Firebug.console##log
        (Data.to_json data' |> Ezjsonm.wrap |> Ezjsonm.to_string)
    in
    Figure.figure [ Graph.bar data ] [ Layout.title "Total Scores" ]
  in
  (* Hook into Bonsai lifecycle to render *)
  let%sub () =
    Bonsai.Edge.lifecycle
      ~on_activate:
        (Bonsai_web.Value.return
           (Ui_effect.of_sync_fun
              (fun () ->
                 let container = Dom_html.getElementById_exn "standings-plot" in
                 (* Render the figure using Plotly_jsoo *)
                 Plotly_jsoo.Jsoo.create container figure)
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
