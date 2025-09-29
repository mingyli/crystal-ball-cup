open! Core

type t = { probabilities : Probability.t Event_id.Map.t } [@@deriving sexp, fields]

let create probabilities = { probabilities }

let of_csv csv =
  let channel = Csv.of_string csv in
  let all_rows = Csv.input_all channel in
  match all_rows with
  | [] -> raise_s [%message "empty csv" (csv : string)]
  | header :: data ->
    let email_idx =
      List.find_mapi_exn header ~f:(fun i h ->
        match String.equal h "Email Address" with
        | true -> Some i
        | false -> None)
    in
    let event_ids =
      List.filter_mapi header ~f:(fun i h ->
        match Int.of_string h with
        | exception _ -> None
        | n -> Some (Event_id.of_int n, i))
    in
    List.map data ~f:(fun row ->
      let respondent = List.nth_exn row email_idx in
      let probabilities =
        List.map event_ids ~f:(fun (e, i) ->
          let p = Probability.of_string (List.nth_exn row i) in
          e, p)
        |> Map.of_alist_exn (module Event_id)
      in
      respondent, { probabilities })
    |> String.Map.of_alist_exn
;;
