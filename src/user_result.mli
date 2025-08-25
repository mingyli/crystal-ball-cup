open! Core

type t [@@deriving sexp_of]

val create : response:Response.t -> scores:Scores.t -> t
val yojson_of_t : t -> Yojson.Safe.t
