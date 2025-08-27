open! Core

type t [@@deriving sexp_of, yojson_of]

val of_csv : string -> t String.Map.t
val probabilities : t -> float Event_id.Map.t
