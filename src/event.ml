open! Core

type t =
  { id : int
  ; short : string
  ; precise : string
  ; outcome : Outcome.t
  }
[@@deriving fields, sexp, yojson_of]

let create = Fields.create
let score t ~probability = Outcome.score t.outcome ~probability

module type Collection = sig
  val all : t list
end
