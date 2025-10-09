open! Core

type t =
  { id : Event_id.t
  ; short : string
  ; precise : string
  ; outcome : Outcome.t option
  }
[@@deriving compare, equal, fields, sexp]

let create = Fields.create

let resolution t =
  let%map.Option outcome = t.outcome in
  Outcome.resolution outcome
;;

let date t =
  let%map.Option outcome = t.outcome in
  Outcome.date outcome
;;

let score t ~(probability : Probability.t) =
  match t.outcome with
  | None -> Float.nan
  | Some outcome -> Outcome.score outcome ~probability
;;
