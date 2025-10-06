open! Core

type t =
  | Yes
  | No
[@@deriving compare, equal, sexp, enumerate]

include Comparable.S with type t := t

val caqti_type : t Caqti_type.t
val to_string : t -> string
val score : t -> probability:Probability.t -> float
