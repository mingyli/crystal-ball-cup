open! Core
open Import

type t =
  { id : Event_id.t
  ; short : string
  ; precise : string
  ; outcome : Outcome.t
  }
[@@deriving compare, equal, fields, sexp, yojson_of]

let create = Fields.create
let score t ~probability = Outcome.score t.outcome ~probability
