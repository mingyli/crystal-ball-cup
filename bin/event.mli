open! Core

type t [@@deriving sexp]

val all : t list
val short : t -> string
val precise : t -> string
