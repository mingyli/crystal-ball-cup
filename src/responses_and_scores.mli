open! Core

type t [@@deriving sexp, yojson_of]

val create : Responses.t -> Scores.t -> t
val of_responses : Collection.t -> Responses.t -> t
val scores : t -> Scores.t
