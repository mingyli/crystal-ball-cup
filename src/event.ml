open! Core

type t =
  { id : Event_id.t
  ; short : string
  ; precise : string
  ; outcome : Outcome.t
  }
[@@deriving compare, equal, fields, sexp]

let create = Fields.create
let score t ~(probability : Probability.t) = Outcome.score t.outcome ~probability
