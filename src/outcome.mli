open! Core

type t [@@deriving compare, equal, sexp]

val create : Resolution.t -> Date.t -> string -> t
val resolution : t -> Resolution.t
val date : t -> Date.t
val explanation : t -> string
val score : t -> probability:Probability.t -> float
