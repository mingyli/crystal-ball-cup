open! Core

type t [@@deriving yojson_of]

val create : Responses.t -> Scores.t -> t
val of_responses : (module Collection.S) -> Responses.t -> t
