open! Core

type t

val create : Responses.t -> Scores.t -> t
val of_responses : Collection.t -> Responses.t -> t
