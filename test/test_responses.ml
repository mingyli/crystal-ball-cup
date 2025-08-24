open! Core
open Crystal

let%expect_test "of_csv" =
  let csv =
    "Timestamp,Email Address,1,2,Feedback\n\
     7/28/2025 23:56:29,abc@gmail.com,0.75,0.9,some feedback\n\
     8/9/2025 15:27:02,def@gmail.com,0.32,0.999,more feedback"
  in
  let responses = Responses.of_csv csv in
  print_s [%sexp (responses : Responses.t String.Map.t)];
  [%expect
    {|
    ((abc@gmail.com ((probabilities ((1 0.75) (2 0.9)))))
     (def@gmail.com ((probabilities ((1 0.32) (2 0.999))))))    |}]
;;

let%expect_test "scale by confidence" =
  let responses =
    Responses.create
    @@ Event_id.Map.of_alist_exn
         [ Event_id.of_int 0, 0.0
         ; Event_id.of_int 2, 0.2
         ; Event_id.of_int 5, 0.5
         ; Event_id.of_int 8, 0.8
         ; Event_id.of_int 10, 1.0
         ]
  in
  let test confidence =
    let scaled_responses = Responses.scale_by_confidence responses ~confidence in
    print_s [%sexp (scaled_responses : Responses.t)]
  in
  test 1.;
  [%expect
    {| ((probabilities ((0 0) (2 0.2) (5 0.5) (8 0.8) (10 1)))) |}];
  test 0.;
  [%expect
    {| ((probabilities ((0 0.5) (2 0.5) (5 0.5) (8 0.5) (10 0.5)))) |}];
  test Float.infinity;
  [%expect {| ((probabilities ((0 0) (2 0) (5 0.5) (8 1) (10 1)))) |}];
  test 2.;
  [%expect
    {|
    ((probabilities
      ((0 0) (2 0.058823529411764705) (5 0.5) (8 0.94117647058823528) (10 1))))
    |}];
  test 0.5;
  [%expect
    {|
    ((probabilities
      ((0 0) (2 0.33333333333333331) (5 0.5) (8 0.66666666666666663) (10 1))))
    |}];
  ()
;;
