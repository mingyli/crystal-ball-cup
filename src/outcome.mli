open! Core

type t =
  | Pending
  | Yes
  | No
[@@deriving sexp, yojson_of]

val caqti_type : t Caqti_type.t
val to_string : t -> string
val score : t -> probability:float -> float
