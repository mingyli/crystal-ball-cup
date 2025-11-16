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
