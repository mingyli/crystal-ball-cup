open! Core

type t [@@deriving yojson_of]

val of_user_event_scores : float Int.Map.t String.Map.t -> t String.Map.t
