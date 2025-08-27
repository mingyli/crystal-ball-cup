open! Core
open Crystal

let name = "2025_test"

let all =
  [ Event.create
      ~id:(Event_id.of_int 1)
      ~short:"Event 1"
      ~precise:"Precise description for event 1"
      ~outcome:Pending
  ; Event.create
      ~id:(Event_id.of_int 2)
      ~short:"Event 2"
      ~precise:"Precise description for event 2"
      ~outcome:Yes
  ; Event.create
      ~id:(Event_id.of_int 3)
      ~short:"Event 3"
      ~precise:"Precise description for event 3"
      ~outcome:No
  ]
;;

include Collection.Make (struct
    let name = name
    let all = all
  end)
