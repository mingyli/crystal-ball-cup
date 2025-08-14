open! Core

type t [@@deriving sexp, yojson_of]

val create : id:int -> short:string -> precise:string -> outcome:Outcome.t -> t
val id : t -> int
val short : t -> string
val precise : t -> string
val outcome : t -> Outcome.t
val score : t -> probability:float -> float

module type Collection = sig
  val all : t list
end
