open! Core

type t =
  { question_scores : float Int.Map.t
  ; mean_score : float
  }

let yojson_of_question_scores question_scores =
  `Assoc
    (Int.Map.to_alist question_scores
     |> List.map ~f:(fun (event_id, score) -> Int.to_string event_id, `Float score))
;;

let yojson_of_t { question_scores; mean_score } =
  `Assoc
    [ "question_scores", yojson_of_question_scores question_scores
    ; "mean_score", `Float mean_score
    ]
;;

let of_user_event_scores user_event_scores =
  Map.map user_event_scores ~f:(fun question_scores ->
    let mean_score =
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
