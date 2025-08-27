open! Core
open Caqti_blocking

let outcome_to_float = function
  | Outcome.Pending -> None
  | Yes -> Some 1.0
  | No -> Some 0.0
;;

let create_events_req =
  let open Caqti_request.Infix in
  (Caqti_type.unit ->. Caqti_type.unit)
    "CREATE TABLE events ( event_id TEXT PRIMARY KEY, short TEXT NOT NULL, precise TEXT \
     NOT NULL, outcome REAL )"
;;

let create_responses_req =
  let open Caqti_request.Infix in
  (Caqti_type.unit ->. Caqti_type.unit)
    "CREATE TABLE responses ( respondent TEXT NOT NULL, event_id TEXT NOT NULL, \
     probability REAL NOT NULL, PRIMARY KEY (respondent, event_id), FOREIGN KEY \
     (event_id) REFERENCES events(event_id) )"
;;

let create_scores_req =
  let open Caqti_request.Infix in
  (Caqti_type.unit ->. Caqti_type.unit)
    "CREATE TABLE scores ( respondent TEXT NOT NULL, event_id TEXT NOT NULL, score REAL \
     NOT NULL, PRIMARY KEY (respondent, event_id), FOREIGN KEY (event_id) REFERENCES \
     events(event_id) )"
;;

let insert_event_req =
  let open Caqti_request.Infix in
  (Caqti_type.(t4 string string string (option float)) ->. Caqti_type.unit)
    "INSERT INTO events (event_id, short, precise, outcome) VALUES (?, ?, ?, ?)"
;;

let insert_response_req =
  let open Caqti_request.Infix in
  (Caqti_type.(t3 string string float) ->. Caqti_type.unit)
    "INSERT INTO responses (respondent, event_id, probability) VALUES (?, ?, ?)"
;;

let insert_score_req =
  let open Caqti_request.Infix in
  (Caqti_type.(t3 string string float) ->. Caqti_type.unit)
    "INSERT INTO scores (respondent, event_id, score) VALUES (?, ?, ?)"
;;

let create_and_populate ~output_path (module C : Collection.S) =
  let open Result.Let_syntax in
  let uri = Uri.of_string ("sqlite3:" ^ output_path) in
  let result =
    let%bind (module Conn : Caqti_blocking.CONNECTION) = connect uri in
    let%bind () = Conn.exec create_events_req () in
    let%bind () = Conn.exec create_responses_req () in
    let%bind () = Conn.exec create_scores_req () in
    let%bind () =
      let events = C.all in
      List.fold events ~init:(Ok ()) ~f:(fun acc event ->
        let%bind () = acc in
        let event_id = Event.id event |> Event_id.to_string in
        let short = Event.short event in
        let precise = Event.precise event in
        let outcome = Event.outcome event |> outcome_to_float in
        Conn.exec insert_event_req (event_id, short, precise, outcome))
    in
    let%bind () =
      let responses_by_respondent =
        In_channel.read_all "etc/2025/responses.csv" |> Responses.of_csv
      in
      Map.fold
        responses_by_respondent
        ~init:(Ok ())
        ~f:(fun ~key:respondent ~data:responses acc ->
          let%bind () = acc in
          Map.fold
            (Responses.probabilities responses)
            ~init:(Ok ())
            ~f:(fun ~key:event_id ~data:probability acc ->
              let%bind () = acc in
              let event_id_str = Event_id.to_string event_id in
              let%bind () =
                Conn.exec insert_response_req (respondent, event_id_str, probability)
              in
              let event = Map.find_exn C.all' event_id in
              let score = Event.score event ~probability in
              Conn.exec insert_score_req (respondent, event_id_str, score)))
    in
    Ok ()
  in
  Result.map_error result ~f:Caqti_error.show
;;
