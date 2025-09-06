open! Core

type t [@@deriving sexp]

val create : float Event_id.Map.t -> t
val of_csv : string -> t String.Map.t
val probabilities : t -> float Event_id.Map.t
