open! Core

type t [@@deriving sexp_of, yojson_of]

val of_csv : string -> t list
val probability : t -> event_id:int -> float
val probabilities : t -> Question_map.t
val user : t -> string
