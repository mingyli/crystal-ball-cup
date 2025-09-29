open! Core

type t =
  | Pending
  | Yes of Explanation.t
  | No of Explanation.t
[@@deriving compare, equal, sexp]

include Comparable.S with type t := t

val caqti_type : t Caqti_type.t

val to_kind : t -> Outcome_kind.t
val to_string : t -> string
val score : t -> probability:Probability.t -> float
