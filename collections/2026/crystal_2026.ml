open! Core
open Crystal

let name = "2026"

let all =
  let pending label short precise = Event.create ~short ~precise ~label ~outcome:None in
  List.mapi
    ~f:(fun i f -> f ~id:(Event_id.of_int (i + 1)))
    [ pending
        "medals"
        "USA wins more silver medals than gold medals at the 2026 Winter Olympics"
        "The number of silver medals the United States of America wins exceeds the \
         number of gold medals the country wins at the 2026 Winter Olympics."
    ; pending
        "oscars"
        "Oscars Best Picture is a streaming movie"
        "The winner of Best Picture at the 98th Academy Awards is a film distributed \
         primarily by a streaming service (e.g., Apple, Netflix, Amazon)."
    ; pending
        "moon"
        "Artemis II successfully orbits the moon"
        "NASA’s Artemis II mission launches, carries a crew around the moon, and returns \
         safely to Earth."
    ]
;;

include Collection.Make (struct
    let name = name
    let all = all
  end)
