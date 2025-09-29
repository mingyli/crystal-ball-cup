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