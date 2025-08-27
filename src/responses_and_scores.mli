open! Core

type t [@@deriving yojson_of]

val create : Responses.t -> Scores.t -> t
