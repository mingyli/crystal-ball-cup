open! Core
open Import

type t = { event_scores : float Event_id.Map.t } [@@deriving fields, sexp_of, yojson_of]

let create collection responses =
  let probabilities = Responses.probabilities responses in
  let events = Collection.all' collection in
  let event_scores =
    Map.merge probabilities events ~f:(fun ~key:event_id -> function
      | `Left probability ->
        raise_s
          [%message
            "No event found for probability" (event_id : Event_id.t) (probability : float)]
      | `Right event ->
        raise_s
          [%message
            "No probability provided for event" (event_id : Event_id.t) (event : Event.t)]
      | `Both (probability, event) -> Some (Event.score event ~probability))
  in
  { event_scores }
;;
