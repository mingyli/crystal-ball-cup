open! Core

type t =
  | Pending
  | Yes
  | No
[@@deriving sexp, yojson]
