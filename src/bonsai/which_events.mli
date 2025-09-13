open! Core
open Crystal

type t =
  | All
  | One of Event.t
[@@deriving compare, equal, sexp_of, variants]

include Comparable.S_plain with type t := t
