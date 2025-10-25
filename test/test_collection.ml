open! Core
open Crystal

let name = "2025_test"

let all =
  [ Event.create
      ~id:(Event_id.of_int 1)
      ~short:"Event1"
      ~precise:"Precise description for event 1"
      ~label:"one"
      ~outcome:None
  ; Event.create
      ~id:(Event_id.of_int 2)
      ~short:"Event2"
      ~precise:"Precise description for event 2"
      ~label:"two"
      ~outcome:
        (Some (Outcome.create Yes (Date.of_string "2025-01-01") "This event happened."))
  ; Event.create
      ~id:(Event_id.of_int 3)
      ~short:"Event3"
      ~precise:"Precise description for event 3"
      ~label:"three"
      ~outcome:
        (Some
           (Outcome.create No (Date.of_string "2025-02-01") "This event did not happen."))
  ]
;;

include Collection.Make (struct
    let name = name
    let all = all
  end)
