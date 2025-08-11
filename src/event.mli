open! Core

type t [@@deriving sexp, yojson_of]

val all : t list
val id : t -> int
val short : t -> string
val precise : t -> string
val score : t -> probability:float -> float
