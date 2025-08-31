open! Core
open Import

type explanation = { link : string; date : string; text : string }
[@@deriving fields, sexp, yojson_of]

type t =
  { id : Event_id.t
  ; short : string
  ; precise : string
  ; outcome : Outcome.t
  ; explanation : explanation option
  }
[@@deriving fields, sexp, yojson_of]

let create = Fields.create
let score t ~probability = Outcome.score t.outcome ~probability
