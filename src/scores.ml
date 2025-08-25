open! Core

type t =
  { question_scores : Question_map.t
  ; mean_score : float
  }
[@@deriving fields, sexp_of, yojson_of]

let of_user_event_scores user_event_scores =
  Map.map user_event_scores ~f:(fun question_scores ->
    let mean_score =
      let question_scores = Question_map.to_map question_scores in
      let count_of_valid_scores =
        Map.data question_scores |> List.count ~f:(fun score -> not (Float.is_nan score))
      in
      if count_of_valid_scores = 0
      then Float.nan
      else (
        let total_sum_of_valid_scores =
          Map.data question_scores
          |> List.filter ~f:(fun score -> not (Float.is_nan score))
          |> List.sum (module Float) ~f:Fn.id
        in
        total_sum_of_valid_scores /. Float.of_int count_of_valid_scores)
    in
    { question_scores; mean_score })
;;
