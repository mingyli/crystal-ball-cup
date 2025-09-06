open! Core

type t [@@deriving compare, sexp]

val of_int : int -> t
val caqti_type : t Caqti_type.t
val to_string : t -> string

include Comparable.S with type t := t
