open! Core

type t =
  | Pending
  | Yes
  | No
[@@deriving sexp, yojson]

val to_string : t -> string
