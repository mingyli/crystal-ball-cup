open! Core
open Crystal

let%expect_test _ =
  let probs = Array.map [| 0.2; 0.6; 0.8 |] ~f:Probability.of_float in
  let outcomes = [| 0.; 0.; 1. |] in
  let optimizer = Confidence_optimizer.create probs outcomes in
  let f =
    List.range 0 9
    |> List.folding_map ~init:1. ~f:(fun confidence step ->
      let loss = Confidence_optimizer.loss optimizer ~confidence in
      let confidence' = Confidence_optimizer.step optimizer ~confidence in
      confidence', (step, confidence, loss))
  in
  let columns =
    let c = Ascii_table.Column.create in
    [ c "Step" (fun (s, _, _) -> Int.to_string s)
    ; c "Confidence" (fun (_, c, _) -> Float.to_string c)
    ; c "Loss" (fun (_, _, l) -> Float.to_string l)
    ]
  in
  print_endline (Ascii_table.to_string columns f ~bars:`Unicode);
  [%expect
    {|
    ┌──────┬────────────────────┬────────────────────┐
    │ Step │ Confidence         │ Loss               │
    ├──────┼────────────────────┼────────────────────┤
    │ 0    │ 1.                 │ 1.3625778345025741 │
    │ 1    │ 1.4755828288580262 │ 1.2795912745270031 │
    │ 2    │ 1.6062174299750058 │ 1.2757921577526976 │
    │ 3    │ 1.615505928617317  │ 1.2757759354973688 │
    │ 4    │ 1.6155501787376678 │ 1.2757759351338076 │
    │ 5    │ 1.6155501797369969 │ 1.275775935133808  │
    │ 6    │ 1.6155501797369969 │ 1.275775935133808  │
    │ 7    │ 1.6155501797369969 │ 1.275775935133808  │
    │ 8    │ 1.6155501797369969 │ 1.275775935133808  │
    └──────┴────────────────────┴────────────────────┘
    |}]
;;
