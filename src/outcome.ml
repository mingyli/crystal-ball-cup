open! Core

type t =
  | Pending
  | Yes
  | No
[@@deriving sexp, yojson_of]

let to_string = function
  | Pending -> "Pending"
  | Yes -> "Yes"
  | No -> "No"
;;

let score t ~probability =
  let ln = Float.log in
  match t with
  | Pending -> Float.nan
  | Yes -> ln probability -. ln 0.5
  | No -> ln (1.0 -. probability) -. ln 0.5
;;

let%expect_test "score" =
  let outcomes = [ Pending; Yes; No ] in
  let probabilities = [ 0.0; 0.1; 0.5; 0.9; 1.0 ] in
  let rows =
    List.cartesian_product outcomes probabilities
    |> List.map ~f:(fun (outcome, probability) ->
      outcome, probability, score outcome ~probability)
  in
  let columns =
    let c = Ascii_table.Column.create in
    [ c "Outcome" (fun (outcome, _, _) -> to_string outcome)
    ; c "Probability" (fun (_, prob, _) -> Float.to_string prob)
    ; c "Score" (fun (_, _, score_val) ->
        if Float.is_nan score_val then "nan" else Float.to_string score_val)
    ]
  in
  print_endline (Ascii_table.to_string columns rows ~bars:`Unicode);
  [%expect {|
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
