open! Core

type t =
  | Pending
  | Yes
  | No
[@@deriving sexp, yojson]

let to_string = function
  | Pending -> "Pending"
  | Yes -> "Yes"
  | No -> "No"
;;
