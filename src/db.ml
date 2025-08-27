open! Core

let create_events_req =
  let open Caqti_request.Infix in
  (Caqti_type.unit ->. Caqti_type.unit)
    "CREATE TABLE events ( event_id INTEGER PRIMARY KEY, short TEXT, precise TEXT, \
     outcome TEXT )"
;;

let create_responses_req =
  let open Caqti_request.Infix in
  (Caqti_type.unit ->. Caqti_type.unit)
    "CREATE TABLE responses ( respondent TEXT NOT NULL, event_id INTEGER NOT NULL, \
     probability REAL NOT NULL, PRIMARY KEY (respondent, event_id), FOREIGN KEY \
     (event_id) REFERENCES events(event_id) )"
;;

let create_scores_req =
  let open Caqti_request.Infix in
  (Caqti_type.unit ->. Caqti_type.unit)
    "CREATE TABLE scores ( respondent TEXT NOT NULL, event_id INTEGER NOT NULL, score \
     REAL, PRIMARY KEY (respondent, event_id), FOREIGN KEY (event_id) REFERENCES \
     events(event_id) )"
;;

let insert_event_req =
  let open Caqti_request.Infix in
  (Caqti_type.(t4 Event_id.caqti_type string string Outcome.caqti_type)
   ->. Caqti_type.unit)
    "INSERT INTO events (event_id, short, precise, outcome) VALUES (?, ?, ?, ?)"
;;

let insert_response_req =
  let open Caqti_request.Infix in
  (Caqti_type.(t3 string Event_id.caqti_type float) ->. Caqti_type.unit)
    "INSERT INTO responses (respondent, event_id, probability) VALUES (?, ?, ?)"
;;

let insert_score_req =
  let open Caqti_request.Infix in
  (Caqti_type.(t3 string Event_id.caqti_type float) ->. Caqti_type.unit)
    "INSERT INTO scores (respondent, event_id, score) VALUES (?, ?, ?)"
;;

let create_and_populate (module Collection : Collection.S) ~output_file ~responses ~scores
  =
  let open Result.Let_syntax in
  let uri = Uri.of_string ("sqlite3:" ^ output_file) in
  let result =
    let%bind (module Conn : Caqti_blocking.CONNECTION) = Caqti_blocking.connect uri in
    let%bind () = Conn.exec create_events_req () in
    let%bind () = Conn.exec create_responses_req () in
    let%bind () = Conn.exec create_scores_req () in
    let%bind () =
      let events = Collection.all in
      List.fold events ~init:(Ok ()) ~f:(fun acc event ->
        let%bind () = acc in
        let event_id = Event.id event in
        let short = Event.short event in
        let precise = Event.precise event in
        let outcome = Event.outcome event in
        Conn.exec insert_event_req (event_id, short, precise, outcome))
    in
    let%bind () =
      Map.fold responses ~init:(Ok ()) ~f:(fun ~key:respondent ~data:responses acc ->
        let%bind () = acc in
        Map.fold
          (Responses.probabilities responses)
          ~init:(Ok ())
          ~f:(fun ~key:event_id ~data:probability acc ->
            let%bind () = acc in
            Conn.exec insert_response_req (respondent, event_id, probability)))
    in
    let%bind () =
      Map.fold scores ~init:(Ok ()) ~f:(fun ~key:respondent ~data:scores acc ->
        let%bind () = acc in
        Map.fold
          (Scores.event_scores scores)
          ~init:(Ok ())
          ~f:(fun ~key:event_id ~data:score acc ->
            let%bind () = acc in
            Conn.exec insert_score_req (respondent, event_id, score)))
    in
    Ok ()
  in
  Result.map_error result ~f:(fun e -> e |> Caqti_error.show |> Error.of_string)
;;


