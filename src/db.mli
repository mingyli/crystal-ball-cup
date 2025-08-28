open! Core

type t

val create : output_file:string -> t

module Connection : sig
  type t

  val make_events : t -> Collection.t -> unit Or_error.t
  val make_responses : t -> Responses.t String.Map.t -> unit Or_error.t
  val make_scores : t -> Scores.t String.Map.t -> unit Or_error.t
  val make_responses_and_scores : t -> unit Or_error.t
end

val with_connection : t -> f:(Connection.t -> unit Or_error.t) -> unit Or_error.t
