open! Core
open Crystal

let () =
  let scores () =
    (* Create fake responses with sample probabilities for some events *)
    let fake_probabilities =
      Event_id.Map.of_alist_exn
        [ Event_id.of_int 1, Random.float 1.0
        ; Event_id.of_int 2, Random.float 1.0
        ; Event_id.of_int 3, Random.float 1.0
        ; Event_id.of_int 4, Random.float 1.0
        ; Event_id.of_int 5, Random.float 1.0
        ; Event_id.of_int 6, Random.float 1.0
        ; Event_id.of_int 7, Random.float 1.0
        ; Event_id.of_int 8, Random.float 1.0
        ; Event_id.of_int 9, Random.float 1.0
        ; Event_id.of_int 10, Random.float 1.0
        ; Event_id.of_int 11, Random.float 1.0
        ; Event_id.of_int 12, Random.float 1.0
        ; Event_id.of_int 13, Random.float 1.0
        ; Event_id.of_int 14, Random.float 1.0
        ; Event_id.of_int 15, Random.float 1.0
        ; Event_id.of_int 16, Random.float 1.0
        ; Event_id.of_int 17, Random.float 1.0
        ; Event_id.of_int 18, Random.float 1.0
        ; Event_id.of_int 19, Random.float 1.0
        ; Event_id.of_int 20, Random.float 1.0
        ]
    in
    let fake_responses = Responses.create fake_probabilities in
    let scores = Scores.create (module Crystal_collections.M2025) fake_responses in
    scores
  in
  let scores = String.Map.of_alist_exn [ "ming", scores (); "obama", scores () ] in
  let computation = App.standings (module Crystal_collections.M2025) scores in
  Bonsai_web.Start.start ~bind_to_element_with_id:"testbonsai" computation
;;
