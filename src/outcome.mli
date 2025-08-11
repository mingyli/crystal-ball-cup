open! Core

type t =
  | Pending
  | Yes
  | No
[@@deriving sexp, yojson_of]

val to_string : t -> string
val score : t -> probability:float -> float
