open! Core

type t =
  { email : string
  ; response : Response.t
  ; scores : Scores.t
  }
[@@deriving sexp_of, fields, yojson_of]

let create ~response ~scores =
  Fields.create ~email:(Response.user response) ~response ~scores
;;
