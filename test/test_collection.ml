open! Core
open Crystal

let name = "2025_test"

let all =
  [ Event.create
      ~id:(Event_id.of_int 1)
      ~short:"Event1"
      ~precise:"Precise description for event 1"
      ~outcome:Pending
  ; Event.create
      ~id:(Event_id.of_int 2)
      ~short:"Event2"
      ~precise:"Precise description for event 2"
      ~outcome:(Yes (Explanation.create ~date:(Date.of_string "2025-01-01") ~description:"Description proving event 2" ~link:"https://www.link.that/proves/event/2" ()))
  ; Event.create
      ~id:(Event_id.of_int 3)
      ~short:"Event3"
      ~precise:"Precise description for event 3"
      ~outcome:(No (Explanation.create ~date:(Date.of_string "2025-12-31") ~description:"Description that describes why event 3 didnt happen" ()))
  ]
;;

include Collection.Make (struct
    let name = name
    let all = all
  end)
