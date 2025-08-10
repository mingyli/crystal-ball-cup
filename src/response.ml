open! Core

type t =
  { email : string
  ; probabilities : float Int.Map.t
  }
[@@deriving sexp_of, fields]

let of_csv csv =
  let channel = Csv.of_string csv in
  let all_rows = Csv.input_all channel in
  match all_rows with
  | [] -> raise_s [%message "empty csv" (csv : string)]
  | header :: data ->
    let email_idx =
      List.find_mapi_exn header ~f:(fun i h ->
        match String.equal h "Email Address" with
        | true -> Some i
        | false -> None)
    in
    let event_ids =
      List.filter_mapi header ~f:(fun i h ->
        match Int.of_string h with
        | exception _ -> None
        | n -> Some (n, i))
    in
    List.map data ~f:(fun row ->
      let email = List.nth_exn row email_idx in
      let probabilities =
        List.map event_ids ~f:(fun (q, i) ->
          let p = Float.of_string (List.nth_exn row i) in
          q, p)
        |> Int.Map.of_alist_exn
      in
      { email; probabilities })
;;

let probability t ~event_id = Map.find_exn t.probabilities event_id
let user t = t.email

let%expect_test "of_csv" =
  let csv =
    "Timestamp,Email Address,1,2,Feedback\n\
     7/28/2025 23:56:29,abc@gmail.com,0.75,0.9,some feedback\n\
     8/9/2025 15:27:02,def@gmail.com,0.32,0.999,more feedback"
  in
  let responses = of_csv csv in
  print_s [%sexp (responses : t list)];
  [%expect
    {|
    (((email abc@gmail.com) (probabilities ((1 0.75) (2 0.9))))
     ((email def@gmail.com) (probabilities ((1 0.32) (2 0.999)))))    |}]
;;
