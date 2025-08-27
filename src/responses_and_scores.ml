open! Core

type t =
  { responses : Responses.t
  ; scores : Scores.t
  }
[@@deriving yojson_of]

let create responses scores = { responses; scores }
