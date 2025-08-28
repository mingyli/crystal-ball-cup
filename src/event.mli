open! Core

type t [@@deriving sexp]

val create : id:Event_id.t -> short:string -> precise:string -> outcome:Outcome.t -> t
val id : t -> Event_id.t
val short : t -> string
val precise : t -> string
val outcome : t -> Outcome.t
val score : t -> probability:float -> float
