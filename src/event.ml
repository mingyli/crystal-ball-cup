open! Core
open Ppx_yojson_conv_lib.Yojson_conv

type t =
  { id : Event_id.t
  ; short : string
  ; precise : string
  ; outcome : Outcome.t
  }
[@@deriving fields, sexp, yojson_of]

let create = Fields.create
let score t ~probability = Outcome.score t.outcome ~probability
