open! Core

type t [@@deriving sexp]

val caqti_type : t Caqti_type.t
val to_float : t -> float
val of_float : float -> t
val to_string : t -> string
val of_string : string -> t

val odds : t -> float
val logit : t -> float
val of_odds : float -> t
val of_logit : float -> t
