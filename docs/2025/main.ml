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
  let plots = Plots.create ~events:Crystal_2025.all ~responses_and_scores in
  let scores = Map.map responses_and_scores ~f:Responses_and_scores.scores in
  (* let standings = Standings.component scores graph in *)
  let sort_by, set_sort_by = Bonsai.state (`Id :> [ `Date | `Id ]) graph in
  let standings2 =
    let standings = Standings2.create Crystal_2025.all scores sort_by in
    Standings2.component standings graph
  in
  let plots = Plots.component plots graph in
  let explorer =
    Explorer.component
      ~db_path:"./crystal.db"
      ~initial_query:"SELECT name, sql FROM sqlite_master WHERE type IN ('table', 'view')"
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
  let%arr
      (* standings = standings
  and *)
        standings2
    =
    standings2
  and plots = plots
  and explorer = explorer
  (* and explorer_winners = explorer_winners  *)
  and sort_by = sort_by
  and set_sort_by = set_sort_by in
  let open Vdom in
  let sort_by_toggle =
    let view_for_value value text =
      let style_attr =
        if phys_equal sort_by value
        then [ Attr.style (Css_gen.font_weight `Bold) ]
        else []
      in
      Node.button
        ~attrs:(Attr.on_click (fun _ -> set_sort_by value) :: style_attr)
        [ Node.text text ]
    in
    Node.div [ view_for_value `Date "Sort by date"; view_for_value `Id "Sort by ID" ]
  in
  Node.div
    [ Node.h2 [ Node.text "Standings" ] (* ; standings *)
    ; sort_by_toggle
    ; standings2
    ; Node.h2 [ Node.text "Events" ]
    ; plots
    ; Node.h2 [ Node.text "Explorer" ]
    ; explorer
    ]
;;

let () = Bonsai_web.Start.start ~bind_to_element_with_id:"app" all
