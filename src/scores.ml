open! Core

type t =
  { event_scores : float Event_id.Map.t
  ; mean_score : float
  }
[@@deriving yojson_of]

let of_respondent_event_scores respondent_event_scores =
  Map.map respondent_event_scores ~f:(fun event_scores ->
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
    { event_scores; mean_score })
;;
