open! Core

type t [@@deriving sexp_of]

val of_csv : string -> t list
val probability : t -> event_id:int -> float
val user : t -> string
