open! Core

type t [@@deriving yojson_of, sexp_of]

val of_map : float Int.Map.t -> t
val to_map : t -> float Int.Map.t
val find : t -> int -> float
