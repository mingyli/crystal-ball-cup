open! Core
open Crystal

let%expect_test "odds and logit" =
  let probabilities =
    [ 0.; 0.01; 0.1; 0.25; 0.5; 0.75; 0.9; 0.99; 1. ] |> List.map ~f:Probability.of_float
  in
  let rows =
    List.map probabilities ~f:(fun p -> p, Probability.odds p, Probability.logit p)
  in
  let columns =
    let c = Ascii_table.Column.create in
    [ c "Probability" (fun (p, _, _) -> Probability.to_string p)
    ; c "Odds" (fun (_, odds, _) -> sprintf "%.3f" odds)
    ; c "Logit" (fun (_, _, logit) -> sprintf "%.3f" logit)
    ]
  in
  print_endline (Ascii_table.to_string columns rows ~bars:`Unicode);
  [%expect
    {|
    ┌─────────────┬────────┬────────┐
    │ Probability │ Odds   │ Logit  │
    ├─────────────┼────────┼────────┤
    │ 0.          │ 0.000  │ -inf   │
    │ 0.01        │ 0.010  │ -4.595 │
    │ 0.1         │ 0.111  │ -2.197 │
    │ 0.25        │ 0.333  │ -1.099 │
    │ 0.5         │ 1.000  │ 0.000  │
    │ 0.75        │ 3.000  │ 1.099  │
    │ 0.9         │ 9.000  │ 2.197  │
    │ 0.99        │ 99.000 │ 4.595  │
    │ 1.          │ inf    │ inf    │
    └─────────────┴────────┴────────┘
    |}]
;;

let%expect_test "scale_by_confidence" =
  let probabilities = [ 0.0; 0.1; 0.5; 0.9; 1.0 ] |> List.map ~f:Probability.of_float in
  let confidences = [ 0.0; 0.5; 1.0; 2.0; Float.infinity ] in
  List.iter confidences ~f:(fun confidence ->
    let rows =
      List.map probabilities ~f:(fun p ->
        p, Probability.scale_by_confidence p ~confidence)
    in
    let columns =
      let c = Ascii_table.Column.create in
      [ c "Probability" (fun (p, _) -> Probability.to_string p)
      ; c "Scaled" (fun (_, s) -> sprintf "%.3f" (Probability.to_float s))
      ]
    in
    print_endline (sprintf "Confidence: %.1f" confidence);
    print_endline (Ascii_table.to_string columns rows ~bars:`Unicode));
  [%expect
    {|
    Confidence: 0.0
    ┌─────────────┬────────┐
    │ Probability │ Scaled │
    ├─────────────┼────────┤
    │ 0.          │ 0.000  │
    │ 0.1         │ 0.500  │
    │ 0.5         │ 0.500  │
    │ 0.9         │ 0.500  │
    │ 1.          │ 1.000  │
    └─────────────┴────────┘

    Confidence: 0.5
    ┌─────────────┬────────┐
    │ Probability │ Scaled │
    ├─────────────┼────────┤
    │ 0.          │ 0.000  │
    │ 0.1         │ 0.250  │
    │ 0.5         │ 0.500  │
    │ 0.9         │ 0.750  │
    │ 1.          │ 1.000  │
    └─────────────┴────────┘

    Confidence: 1.0
    ┌─────────────┬────────┐
    │ Probability │ Scaled │
    ├─────────────┼────────┤
    │ 0.          │ 0.000  │
    │ 0.1         │ 0.100  │
    │ 0.5         │ 0.500  │
    │ 0.9         │ 0.900  │
    │ 1.          │ 1.000  │
    └─────────────┴────────┘

    Confidence: 2.0
    ┌─────────────┬────────┐
    │ Probability │ Scaled │
    ├─────────────┼────────┤
    │ 0.          │ 0.000  │
    │ 0.1         │ 0.012  │
    │ 0.5         │ 0.500  │
    │ 0.9         │ 0.988  │
    │ 1.          │ 1.000  │
    └─────────────┴────────┘

    Confidence: inf
    ┌─────────────┬────────┐
    │ Probability │ Scaled │
    ├─────────────┼────────┤
    │ 0.          │ 0.000  │
    │ 0.1         │ 0.000  │
    │ 0.5         │ 0.500  │
    │ 0.9         │ 1.000  │
    │ 1.          │ 1.000  │
    └─────────────┴────────┘
    |}]
;;
