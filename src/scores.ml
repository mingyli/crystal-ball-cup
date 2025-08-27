open! Core

type t =
  { event_scores : float Event_id.Map.t
  ; mean_score : float
  }
[@@deriving sexp_of, yojson_of]

let create (module Collection : Collection.S) responses =
  let probabilities = Responses.probabilities responses in
  let events = Collection.all' in
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
  let mean_score =
    let count_of_valid_scores =
      Map.data event_scores |> List.count ~f:(fun score -> not (Float.is_nan score))
    in
    if count_of_valid_scores = 0
    then Float.nan
    else (
      let total_sum_of_valid_scores =
        Map.data event_scores
        |> List.filter ~f:(fun score -> not (Float.is_nan score))
        |> List.sum (module Float) ~f:Fn.id
      in
      total_sum_of_valid_scores /. Float.of_int count_of_valid_scores)
  in
  { event_scores; mean_score }
;;
