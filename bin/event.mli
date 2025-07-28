open! Core

type t [@@deriving sexp, yojson]

val all : t list
val short : t -> string
val precise : t -> string
