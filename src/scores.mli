open! Core

type t [@@deriving yojson_of, sexp_of]

val of_user_event_scores : Question_map.t String.Map.t -> t String.Map.t
val question_scores : t -> Question_map.t
val mean_score : t -> float
