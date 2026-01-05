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

let writeup graph =
  let open Vdom in
  let%sub explorer_least_surprising =
    Explorer.component
      graph
      ~db_path:"../2025/crystal.db"
      ~initial_query:
        {|SELECT
  e.short AS least_surprising,
  ROUND(SUM(s.score), 2) AS total_score
FROM scores as s
JOIN events as e
  ON s.event_id = e.event_id
GROUP BY e.event_id
ORDER BY total_score DESC
LIMIT 5|}
      ~interactive:false
  in
  let%sub explorer_most_surprising =
    Explorer.component
      graph
      ~db_path:"../2025/crystal.db"
      ~initial_query:
        {|SELECT
  e.short AS most_surprising,
  ROUND(SUM(s.score), 2) AS total_score
FROM scores as s
JOIN events as e
  ON s.event_id = e.event_id
GROUP BY e.event_id
ORDER BY total_score ASC
LIMIT 5|}
      ~interactive:false
  in
  let%sub explorer_maverick =
    Explorer.component
      graph
      ~db_path:"../2025/crystal.db"
      ~interactive:false
      ~initial_query:
        {|WITH event_averages AS (
  SELECT event_id, AVG(probability) as avg_prob
  FROM responses
  GROUP BY event_id
)
SELECT
  r.respondent,
  ROUND(AVG(ABS(r.probability - ea.avg_prob)), 2) as nonconformity
FROM responses r
JOIN event_averages ea ON r.event_id = ea.event_id
GROUP BY r.respondent
ORDER BY nonconformity DESC
LIMIT 3|}
  in
  let%sub explorer_fence_sitter =
    Explorer.component
      graph
      ~db_path:"../2025/crystal.db"
      ~interactive:false
      ~initial_query:
        {|SELECT
  respondent,
  ROUND(AVG(ABS(probability - 0.5)), 3) as boldness
FROM responses
GROUP BY respondent
ORDER BY boldness ASC
LIMIT 3|}
  in
  let%sub explorer_binary_champion =
    Explorer.component
      graph
      ~db_path:"../2025/crystal.db"
      ~interactive:false
      ~initial_query:
        {|SELECT
  r.respondent,
  SUM(
    CASE
      WHEN (r.probability > 0.5 AND o.resolution = 'Yes') THEN 1
      WHEN (r.probability < 0.5 AND o.resolution = 'No') THEN 1
      ELSE 0
    END
  ) as correct
FROM responses r
JOIN outcomes o ON r.event_id = o.event_id
GROUP BY r.respondent
ORDER BY correct DESC
LIMIT 5|}
  in
  let%sub explorer_directionally_challenged =
    Explorer.component
      graph
      ~db_path:"../2025/crystal.db"
      ~interactive:false
      ~initial_query:
        {|SELECT
  r.respondent,
  SUM(
    CASE
      WHEN (r.probability > 0.5 AND o.resolution = 'No') THEN 1
      WHEN (r.probability < 0.5 AND o.resolution = 'Yes') THEN 1
      ELSE 0
    END
  ) as incorrect
FROM responses r
JOIN outcomes o ON r.event_id = o.event_id
GROUP BY r.respondent
ORDER BY incorrect DESC
LIMIT 3|}
  in
  let%sub explorer_winners =
    Explorer.component
      graph
      ~db_path:"../2025/crystal.db"
      ~initial_query:
        {|SELECT
  respondent AS winner,
  ROUND(SUM(score), 2) AS total_score
FROM scores
GROUP BY respondent
ORDER BY total_score DESC
LIMIT 3|}
      ~interactive:false
  in
  let%sub explorer_losers =
    Explorer.component
      graph
      ~db_path:"../2025/crystal.db"
      ~initial_query:
        {|SELECT
  respondent AS loser,
  ROUND(SUM(score), 2) AS total_score,
  SUM(
    CASE
      WHEN CAST(score AS TEXT) = '-Inf'
      THEN 1
      ELSE 0
    END
  ) AS inf_count
FROM scores
GROUP BY respondent
ORDER BY total_score ASC, inf_count DESC
LIMIT 3|}
      ~interactive:false
  in
  let%arr explorer_least_surprising = explorer_least_surprising
  and explorer_most_surprising = explorer_most_surprising
  and explorer_maverick = explorer_maverick
  and explorer_fence_sitter = explorer_fence_sitter
  and explorer_binary_champion = explorer_binary_champion
  and explorer_directionally_challenged = explorer_directionally_challenged
  and explorer_winners = explorer_winners
  and explorer_losers = explorer_losers in
  Node.div
    [ Node.h2 [ Node.text "Superlatives" ]
    ; Node.h3 [ Node.text "Surprise" ]
    ; Node.p
        [ Node.text
            "For the inaugural rendition of Crystal Ball Cup we had an impressive \
             showing of twenty-four participants. A majority ended up with positive \
             scores, meaning they came up with predictions that were better than \
             guessing 50% on every event. I'll have to come up with more surprising \
             events next year!"
        ]
    ; Node.p
        [ Node.text
            "Let's say one event is more surprising than another event if the sum of the \
             scores for that event is lower than that of the other event. Here are the \
             least and most surprising events:"
        ]
    ; Node.div
        ~attrs:
          [ {%css|
        display: grid;
        grid-template-columns: 1fr 1fr;
        grid-gap: 3em;
        padding: 1em;
        |}
          ]
        [ explorer_least_surprising; explorer_most_surprising ]
    ; Node.p
        [ Node.text
            "My favorite events from this list were \"White Christmas in New York\" \
             which just barely resolved to No as it snowed on the 26th, and \"Faker wins \
             Worlds\" which was an upset to everyone except a few believers including \
             me."
        ]
    ; Node.h3 [ Node.text "Maverick" ]
    ; Node.p
        [ Node.text
            "The Maverick was the participant who deviated the most from group consensus."
        ]
    ; Node.div ~attrs:[ {%css| padding: 1em |} ] [ explorer_maverick ]
    ; Node.h3 [ Node.text "Fence Sitter" ]
    ; Node.p
        [ Node.text
            "The Fence Sitter was the participant who submitted probabilities closest to \
             50%."
        ]
    ; Node.div ~attrs:[ {%css| padding: 1em |} ] [ explorer_fence_sitter ]
    ; Node.h3 [ Node.text "Binary Champion" ]
    ; Node.p
        [ Node.text
            "The Binary Champion was the participant with the highest directional \
             accuracy, submitting a probability greater than 50% when the outcome was \
             Yes and less than 50% when the outcome was No."
        ]
    ; Node.div ~attrs:[ {%css| padding: 1em |} ] [ explorer_binary_champion ]
    ; Node.h3 [ Node.text "Directionally Challenged" ]
    ; Node.p [ Node.text "On the flip side, we have the Directionally Challenged." ]
    ; Node.div ~attrs:[ {%css| padding: 1em |} ] [ explorer_directionally_challenged ]
    ; Node.h3 [ Node.text "Final Results" ]
    ; Node.p
        [ Node.text
            "Finally, congratulations to our winners and losers. We had the fortune of \
             having two participants who were utterly surprised by Taylor Swift's \
             engagement, resulting in scores of negative infinity. So I'm breaking ties \
             by counting the number of negative infinity scores."
        ]
    ; Node.div
        ~attrs:
          [ {%css|
          display: grid;
          grid-template-columns: 1fr 1fr;
          grid-gap: 3em;
          padding: 1em;
          |}
          ]
        [ explorer_winners; explorer_losers ]
    ; Node.p
        [ Node.text
            "In particular, kudos to the Malik brothers for taking absolute first and \
             last."
        ]
    ; Node.p [ Node.text "Explore all the data below." ]
    ]
;;

let all graph =
  let plots = Plots.create ~events:Crystal_2025.all ~responses_and_scores in
  let scores = Map.map responses_and_scores ~f:Responses_and_scores.scores in
  let writeup = writeup graph in
  let standings =
    Standings.component
      ~start_date:(Date.of_string "2025-08-09")
      ~end_date:(Date.of_string "2025-12-31")
      Crystal_2025.all
      scores
      graph
  in
  let plots = Plots.component plots graph in
  let explorer =
    Explorer.component
      ~db_path:"./crystal.db"
      ~initial_query:
        {|SELECT
  name, sql
FROM
  sqlite_master
WHERE
  type IN ('table', 'view')|}
      graph
  in
  let%arr writeup = writeup
  and standings = standings
  and plots = plots
  and explorer = explorer in
  let open Vdom in
  Node.div
    [ writeup
    ; Node.h2 [ Node.text "Standings" ]
    ; standings
    ; Node.h2 [ Node.text "Events" ]
    ; plots
    ; Node.h2 [ Node.text "Explorer" ]
    ; explorer
    ]
;;

let () = Bonsai_web.Start.start ~bind_to_element_with_id:"app" all
