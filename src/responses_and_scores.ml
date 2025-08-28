open! Core

type t =
  { responses : Responses.t
  ; scores : Scores.t
  }
[@@deriving yojson_of]

let create responses scores = { responses; scores }

let of_responses collection responses =
  create responses (Scores.create collection responses)
;;
