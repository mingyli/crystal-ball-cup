open! Core

type t [@@deriving sexp]

val create : Responses.t -> Scores.t -> t
val of_responses : Collection.t -> Responses.t -> t
val responses : t -> Responses.t
val scores : t -> Scores.t
