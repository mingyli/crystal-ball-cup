open! Core

module Kind : sig
  type t =
    | Pending
    | Yes
    | No
  [@@deriving compare, equal, sexp, enumerate]

  include Comparable.S with type t := t

  val to_string : t -> string
  val score : t -> probability:Probability.t -> float
end

type t =
  | Pending
  | Yes of Explanation.t
  | No of Explanation.t
[@@deriving compare, equal, sexp]

include Comparable.S with type t := t

val caqti_type : t Caqti_type.t
val kind : t -> Kind.t
val to_string : t -> string
val score : t -> probability:Probability.t -> float
