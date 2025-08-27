open! Core

type t [@@deriving sexp_of]

val of_csv : string -> t list
val probability : t -> Event_id.t -> float
val respondent : t -> string
