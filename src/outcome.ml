open! Core

module T = struct
  type t =
    | Pending
    | Yes
    | No
  [@@deriving compare, equal, sexp, enumerate]
end

include T
include Comparable.Make (T)

let to_string = function
  | Pending -> "Pending"
  | Yes -> "Yes"
  | No -> "No"
;;

let of_string = function
  | "Pending" -> Ok Pending
  | "Yes" -> Ok Yes
  | "No" -> Ok No
  | s -> Error [%string "unknown outcome %{s}"]
;;

let score t ~probability =
  let ln = Float.log in
  match t with
  | Pending -> Float.nan
  | Yes -> ln probability -. ln 0.5
  | No -> ln (1.0 -. probability) -. ln 0.5
;;

let caqti_type = Caqti_type.enum "Outcome.t" ~encode:to_string ~decode:of_string
