open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Crystal

let responses_and_scores =
  [%blob "./etc/2025/responses_and_scores.sexp"]
  |> Sexp.of_string
  |> [%of_sexp: Responses_and_scores.t String.Map.t]
;;

let all =
  let%sub multi_select = Multi_select.bonsai_computation in
  let%sub standings =
    let scores = Map.map responses_and_scores ~f:Responses_and_scores.scores in
    App.standings scores
  in
  let%sub text_form = Text_form.component in
  let%sub textbox = Textbox.component in
  let%sub explorer = Explorer.component ~db_path:"../2025/crystal.db" in
  let%arr multi_select = multi_select
  and standings = standings
  and text_form = text_form
  and textbox = textbox
  and explorer = explorer in
  Vdom.Node.div [ multi_select; standings; text_form; textbox; explorer ]
;;

let () = Bonsai_web.Start.start ~bind_to_element_with_id:"app" all
