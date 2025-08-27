open! Core

type t [@@deriving sexp_of, yojson_of]

val create : (module Collection.S) -> Responses.t -> t
val event_scores : t -> float Event_id.Map.t
