open! Core

type t [@@deriving yojson_of]

val of_respondent_event_scores : float Event_id.Map.t String.Map.t -> t String.Map.t
