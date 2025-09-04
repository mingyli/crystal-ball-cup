open! Core
module Bonsai = Bonsai.Cont
open Bonsai.Let_syntax
open Bonsai_web.Cont
open Crystal
open Crystal_bonsai

let responses_and_scores =
  [%blob "./etc/2025/responses_and_scores.sexp"]
  |> Sexp.of_string
  |> [%of_sexp: Responses_and_scores.t String.Map.t]
;;

let all graph =
  let plots = Plots.create ~events:Crystal_collections.M2025.all ~responses_and_scores in
  let standings =
    let scores = Map.map responses_and_scores ~f:Responses_and_scores.scores in
    Standings.component scores graph
  in
  let plots = Plots.component plots graph in
  let explorer =
    Explorer.component
      ~db_path:"../2025/crystal.db"
      ~initial_query:"SELECT name, sql FROM sqlite_master WHERE type = 'table'"
      graph
  in
  (* let%sub explorer_winners =
    Explorer.component
      ~db_path:"../2025/crystal.db"
      ~initial_query:
        {|SELECT respondent, SUM(score) AS total_score
FROM scores
GROUP BY respondent
ORDER BY total_score DESC
LIMIT 3|}
  in *)
  let%arr standings = standings
  and plots = plots
  and explorer =
    explorer
    (* and explorer_winners = explorer_winners  *)
  in
  let open Vdom in
  Node.div
    [ Node.h2 [ Node.text "Standings" ]
    ; standings
    ; Node.h2 [ Node.text "Events" ]
    ; plots
    ; Node.h2 [ Node.text "Explorer" ]
    ; explorer
    ]
;;

let () = Bonsai_web.Start.start ~bind_to_element_with_id:"app" all
