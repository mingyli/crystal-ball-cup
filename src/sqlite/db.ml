open! Core
open Crystal

module Queries = struct
  open Caqti_request.Infix

  let create_events =
    (Caqti_type.unit ->. Caqti_type.unit)
      "CREATE TABLE events ( event_id INTEGER PRIMARY KEY, short TEXT, precise TEXT, \
       outcome TEXT )"
  ;;

  let create_responses =
    (Caqti_type.unit ->. Caqti_type.unit)
      "CREATE TABLE responses ( respondent TEXT NOT NULL, event_id INTEGER NOT NULL, \
       probability REAL NOT NULL, PRIMARY KEY (respondent, event_id), FOREIGN KEY \
       (event_id) REFERENCES events(event_id) )"
  ;;

  let create_scores =
    (Caqti_type.unit ->. Caqti_type.unit)
      "CREATE TABLE scores ( respondent TEXT NOT NULL, event_id INTEGER NOT NULL, score \
       REAL, PRIMARY KEY (respondent, event_id), FOREIGN KEY (event_id) REFERENCES \
       events(event_id) )"
  ;;

  let insert_event =
    (Caqti_type.(t4 Event_id.caqti_type string string Outcome.caqti_type)
     ->. Caqti_type.unit)
      "INSERT INTO events (event_id, short, precise, outcome) VALUES (?, ?, ?, ?)"
  ;;

  let insert_response =
    (Caqti_type.(t3 string Event_id.caqti_type Probability.caqti_type) ->. Caqti_type.unit)
      "INSERT INTO responses (respondent, event_id, probability) VALUES (?, ?, ?)"
  ;;

  let insert_score =
    (Caqti_type.(t3 string Event_id.caqti_type float) ->. Caqti_type.unit)
      "INSERT INTO scores (respondent, event_id, score) VALUES (?, ?, ?)"
  ;;

  let create_responses_and_scores_view =
    (Caqti_type.unit ->. Caqti_type.unit)
      {| CREATE VIEW responses_and_scores AS
           SELECT
             r.respondent,
             r.event_id,
             r.probability,
             s.score
           FROM responses AS r
           JOIN scores AS s
             ON r.respondent = s.respondent AND r.event_id = s.event_id
        |}
  ;;
end

module Connection = struct
  type t = (module Caqti_blocking.CONNECTION)

  open Result.Let_syntax

  let caqti_or_error result =
    result |> Result.map_error ~f:(fun e -> Caqti_error.Exn e) |> Or_error.of_exn_result
  ;;

  let make_events ((module Conn) : t) collection =
    let%bind () = Conn.exec Queries.create_events () in
    let events = Collection.all collection in
    List.fold events ~init:(Ok ()) ~f:(fun acc event ->
      let%bind () = acc in
      let event_id = Event.id event in
      let short = Event.short event in
      let precise = Event.precise event in
      let outcome = Event.outcome event in
      Conn.exec Queries.insert_event (event_id, short, precise, outcome))
  ;;

  let make_events t collection = make_events t collection |> caqti_or_error

  let make_responses ((module Conn) : t) responses =
    let%bind () = Conn.exec Queries.create_responses () in
    Map.fold responses ~init:(Ok ()) ~f:(fun ~key:respondent ~data:responses acc ->
      let%bind () = acc in
      Map.fold
        (Responses.probabilities responses)
        ~init:(Ok ())
        ~f:(fun ~key:event_id ~data:probability acc ->
          let%bind () = acc in
          Conn.exec Queries.insert_response (respondent, event_id, probability)))
  ;;

  let make_responses t responses = make_responses t responses |> caqti_or_error

  let make_scores ((module Conn) : t) scores =
    let%bind () = Conn.exec Queries.create_scores () in
    Map.fold scores ~init:(Ok ()) ~f:(fun ~key:respondent ~data:scores acc ->
      let%bind () = acc in
      Map.fold
        (Scores.event_scores scores)
        ~init:(Ok ())
        ~f:(fun ~key:event_id ~data:score acc ->
          let%bind () = acc in
          Conn.exec Queries.insert_score (respondent, event_id, score)))
  ;;

  let make_scores t scores = make_scores t scores |> caqti_or_error

  let make_responses_and_scores ((module Conn) : t) =
    let work () = Conn.exec Queries.create_responses_and_scores_view () in
    Conn.with_transaction work |> caqti_or_error
  ;;
end

type t = { uri : Uri.t }

let create ~output_file = { uri = Uri.of_string ("sqlite3:" ^ output_file) }

let with_connection t ~f =
  match Caqti_blocking.connect t.uri with
  | Ok connection -> f connection
  | Error e -> Or_error.error_string (Caqti_error.show e)
;;
