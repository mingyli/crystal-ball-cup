open! Core
open Crystal

let%expect_test "score" =
  let outcomes : Outcome.t list = [ Pending; Yes (Explanation.create ~link:"https://www.link.why/yes" ~date:(Date.of_string "2025-01-01") ~description:"Description of why yes" ()); No (Explanation.create ~date:(Date.of_string "2025-12-31") ~description:"Description that describes why not" ()) ] in
  let probabilities = [ 0.0; 0.1; 0.5; 0.9; 1.0 ] |> List.map ~f:Probability.of_float in
  let rows =
    List.cartesian_product outcomes probabilities
    |> List.map ~f:(fun (outcome, probability) ->
      outcome, probability, Outcome.score outcome ~probability)
  in
  let columns =
    let c = Ascii_table.Column.create in
    [ c "Outcome" (fun (outcome, _, _) -> Outcome.to_string outcome)
    ; c "Probability" (fun (_, prob, _) -> Probability.to_string prob)
    ; c "Score" (fun (_, _, score_val) ->
        if Float.is_nan score_val then "nan" else Float.to_string score_val)
    ]
  in
  print_endline (Ascii_table.to_string columns rows ~bars:`Unicode);
  [%expect
    {|
    ┌─────────┬─────────────┬─────────────────────┐
    │ Outcome │ Probability │ Score               │
    ├─────────┼─────────────┼─────────────────────┤
    │ Pending │ 0.          │ nan                 │
    │ Pending │ 0.1         │ nan                 │
    │ Pending │ 0.5         │ nan                 │
    │ Pending │ 0.9         │ nan                 │
    │ Pending │ 1.          │ nan                 │
    │ Yes     │ 0.          │ -inf                │
    │ Yes     │ 0.1         │ -1.6094379124341    │
    │ Yes     │ 0.5         │ 0.                  │
    │ Yes     │ 0.9         │ 0.58778666490211906 │
    │ Yes     │ 1.          │ 0.69314718055994529 │
    │ No      │ 0.          │ 0.69314718055994529 │
    │ No      │ 0.1         │ 0.58778666490211906 │
    │ No      │ 0.5         │ 0.                  │
    │ No      │ 0.9         │ -1.6094379124341005 │
    │ No      │ 1.          │ -inf                │
    └─────────┴─────────────┴─────────────────────┘ |}]
;;
