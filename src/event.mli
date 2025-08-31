open! Core

type explanation = { link : string; date : string; text : string }
[@@deriving sexp, yojson_of]

type t [@@deriving sexp, yojson_of]

val create : id:Event_id.t -> short:string -> precise:string -> outcome:Outcome.t -> explanation:explanation option -> t
val id : t -> Event_id.t
val short : t -> string
val precise : t -> string
val outcome : t -> Outcome.t
val score : t -> probability:float -> float
val explanation : t -> explanation option