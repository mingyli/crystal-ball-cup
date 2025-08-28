open! Core

type t [@@deriving sexp_of, yojson_of]

val create : Collection.t -> Responses.t -> t
val event_scores : t -> float Event_id.Map.t
