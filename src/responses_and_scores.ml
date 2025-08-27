open! Core

type t =
  { responses : Responses.t
  ; scores : Scores.t
  }
[@@deriving yojson_of]

let create responses scores = { responses; scores }

let of_responses (module Collection : Collection.S) responses =
  create responses (Scores.create (module Collection) responses)
;;
