open! Core

type t = float Int.Map.t [@@deriving sexp_of]

let of_map t = t
let to_map t = t
let find t question_id = Map.find_exn t question_id

let yojson_of_t t =
  `Assoc
    (Int.Map.to_alist t
     |> List.map ~f:(fun (event_id, score) -> Int.to_string event_id, `Float score))
;;
