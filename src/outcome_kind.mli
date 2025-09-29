open! Core

type t =
  | Pending
  | Yes
  | No
[@@deriving compare, equal, sexp, enumerate]

include Comparable.S with type t := t

val to_string : t -> string

