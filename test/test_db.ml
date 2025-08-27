open! Core
open Crystal

let dummy_responses =
  String.Map.of_alist_exn
    [ ( "respondent1"
      , Responses.create
        @@ Event_id.Map.of_alist_exn [ Event_id.of_int 1, 0.5; Event_id.of_int 2, 0.8 ] )
    ; ( "respondent2"
      , Responses.create
        @@ Event_id.Map.of_alist_exn [ Event_id.of_int 1, 0.2; Event_id.of_int 2, 0.9 ] )
    ]
;;

let dummy_scores =
  Map.map dummy_responses ~f:(fun responses ->
    Scores.create (module Test_collection) responses)
;;

let max_score_per_respondent_query =
  let open Caqti_request.Infix in
  (Caqti_type.unit ->* Caqti_type.(t3 string string float))
    {|SELECT s.respondent, e.short AS event_short, s.score 
      FROM scores s 
      JOIN events e 
      ON s.event_id = e.event_id 
      WHERE s.score = (
        SELECT MAX(score) FROM scores WHERE respondent = s.respondent
        );|}
;;

let%expect_test _ =
  let open Result.Let_syntax in
  let output_file = Filename.temp_file "test_db" ".sqlite" in
  let () =
    Db.create_and_populate
      (module Test_collection)
      ~output_file
      ~responses:dummy_responses
      ~scores:dummy_scores
    |> Or_error.ok_exn
  in
  print_endline "Database created successfully.";
  let result =
    let uri = Uri.of_string ("sqlite3:" ^ output_file) in
    let%bind (module Conn : Caqti_blocking.CONNECTION) = Caqti_blocking.connect uri in
    let%bind rows = Conn.collect_list max_score_per_respondent_query () in
    List.iter rows ~f:(fun (respondent, event_short, score) ->
      print_endline [%string "%{respondent} %{event_short} %{score#Float}"]);
    Sys.remove output_file;
    Ok ()
  in
  Result.map_error result ~f:(fun e -> e |> Caqti_error.show |> Error.of_string)
  |> Or_error.ok_exn;
  [%expect
    {| 
    Database created successfully.
    respondent1 Event 2 0.47000362924573558
    respondent2 Event 2 0.58778666490211906 |}]
;;
