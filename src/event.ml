open! Core

type t =
  { id : Event_id.t
  ; short : string
  ; precise : string
  ; outcome : Outcome.t
  }
[@@deriving compare, equal, fields, sexp]

let create = Fields.create
let score t ~probability = Outcome.score t.outcome ~probability

let compare_by_outcome_date t1 t2 =
  (* For equality, compare event id *)
  let id_cmp = Event_id.compare t1.id t2.id in
  if id_cmp = 0 then 0
  else
    match t1.outcome, t2.outcome with
    (* If both are pending, sort alphabetically by short text *)
    | Pending, Pending -> String.compare t1.short t2.short
    (* If one is pending and other is resolved, pending goes last *)
    | Pending, (Yes _ | No _) -> 1
    | (Yes _ | No _), Pending -> -1
    (* If both are resolved, sort by outcome date *)
    | (Yes exp1 | No exp1), (Yes exp2 | No exp2) ->
      Date.compare (Explanation.date exp1) (Explanation.date exp2)
