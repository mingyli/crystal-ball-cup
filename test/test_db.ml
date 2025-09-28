open! Core
open Crystal
open Crystal_sqlite

let dummy_responses =
  let event = Event_id.of_int in
  let responses l =
    Responses.create
    @@ Event_id.Map.of_alist_exn
         (List.map l ~f:(fun (id, p) -> id, Probability.of_float p))
  in
  String.Map.of_alist_exn
    [ "respondent1", responses [ event 1, 0.5; event 2, 0.5; event 3, 0.8 ]
    ; "respondent2", responses [ event 1, 0.2; event 2, 0.9; event 3, 0.5 ]
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

let max_score_per_respondent_from_responses_and_scores_query =
  let open Caqti_request.Infix in
  (Caqti_type.unit ->* Caqti_type.(t3 string string float))
    {|SELECT rs.respondent, e.short AS event_short, rs.score
      FROM responses_and_scores rs
      JOIN events e
      ON rs.event_id = e.event_id
      WHERE rs.score = (
        SELECT MAX(score) FROM responses_and_scores WHERE respondent = rs.respondent
        );|}
;;

let%expect_test _ =
  let output_file = Filename_unix.temp_file "test_db" ".sqlite" in
  let db = Db.create ~output_file in
  let () =
    Db.with_connection db ~f:(fun conn ->
      let%bind.Or_error () = Db.Connection.make_events conn (module Test_collection) in
      let%bind.Or_error () = Db.Connection.make_responses conn dummy_responses in
      let%bind.Or_error () = Db.Connection.make_scores conn dummy_scores in
      let%bind.Or_error () = Db.Connection.make_responses_and_scores conn in
      Ok ())
    |> Or_error.ok_exn
  in
  let result =
    let open Result.Let_syntax in
    let uri = Uri.of_string ("sqlite3:" ^ output_file) in
    let%bind (module Conn : Caqti_blocking.CONNECTION) = Caqti_blocking.connect uri in
    let print_results query =
      let%bind rows = Conn.collect_list query () in
      List.iter rows ~f:(fun (respondent, event_short, score) ->
        print_endline
          [%string
            "%{respondent} scored the highest on %{event_short} with a score of \
             %{score#Float}"]);
      Ok ()
    in
    let%bind () = print_results max_score_per_respondent_query in
    [%expect
      {|
      respondent1 scored the highest on Event2 with a score of 0.
      respondent2 scored the highest on Event2 with a score of 0.58778666490211906 |}];
    let%bind () =
      print_results max_score_per_respondent_from_responses_and_scores_query
    in
    [%expect
      {|
      respondent1 scored the highest on Event2 with a score of 0.
      respondent2 scored the highest on Event2 with a score of 0.58778666490211906 |}];
    Ok ()
  in
  Sys_unix.remove output_file;
  Caqti_blocking.or_fail result
;;
