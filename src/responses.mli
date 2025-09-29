open! Core

type t [@@deriving sexp]

val create : Probability.t Event_id.Map.t -> t
val of_csv : string -> t String.Map.t
val probabilities : t -> Probability.t Event_id.Map.t
