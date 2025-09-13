open! Core

module T = struct
  type t =
    | None
    | One of string
  [@@deriving compare, equal, sexp, variants]
end

include T
include Comparable.Make (T)
