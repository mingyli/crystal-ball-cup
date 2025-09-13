open! Core

type t =
  | None
  | One of string
[@@deriving compare, equal, sexp, variants]

include Comparable.S with type t := t
