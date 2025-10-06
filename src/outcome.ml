open! Core

type t =
  { resolution : Resolution.t
  ; date : Date.t
  ; explanation : string
  }
[@@deriving compare, equal, fields, sexp]

let create resolution date explanation = { resolution; date; explanation }
let score t ~probability = Resolution.score t.resolution ~probability
