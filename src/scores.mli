open! Core

type t [@@deriving sexp]

val create : Collection.t -> Responses.t -> t
val event_score : t -> Event_id.t -> float
val event_scores : t -> float Event_id.Map.t
val total : t -> float
