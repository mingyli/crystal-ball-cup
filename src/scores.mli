open! Core

type t [@@deriving yojson_of]

val create : (module Collection.S) -> Responses.t -> t
