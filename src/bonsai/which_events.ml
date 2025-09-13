open! Core
open Crystal

module T = struct
  type t =
    | All
    | One of Event.t
  [@@deriving compare, equal, sexp_of, variants]
end

include T
include Comparable.Make_plain (T)
