open! Core

type t [@@deriving compare, equal, sexp]

val create
  :  id:Event_id.t
  -> short:string
  -> precise:string
  -> label:string
  -> outcome:Outcome.t option
  -> t

val id : t -> Event_id.t
val short : t -> string
val precise : t -> string
val label : t -> string
val outcome : t -> Outcome.t option
val resolution : t -> Resolution.t option
val date : t -> Date.t option
val score : t -> probability:Probability.t -> float
