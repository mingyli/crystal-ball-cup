open! Core

module Kind = struct
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

  let score t ~probability =
    let probability = Probability.to_float probability in
    let ln = Float.log in
    match t with
    | Pending -> Float.nan
    | Yes -> ln probability -. ln 0.5
    | No -> ln (1.0 -. probability) -. ln 0.5
  ;;
end

module T = struct
  type t =
    | Pending
    | Yes of Explanation.t
    | No of Explanation.t
  [@@deriving compare, equal, sexp]
end

include T
include Comparable.Make (T)

let kind : t -> Kind.t = function
  | Pending -> Pending
  | Yes _ -> Yes
  | No _ -> No
;;

let score t ~probability = Kind.score (kind t) ~probability
let to_string t = Kind.to_string (kind t)

let caqti_type =
  let encode t =
    try
      let sexp = sexp_of_t t in
      Ok (Sexp.to_string sexp)
    with
    | exn -> Error ("Failed to encode outcome: " ^ Exn.to_string exn)
  in
  let decode sexp_str =
    try
      let sexp = Sexp.of_string sexp_str in
      let outcome = t_of_sexp sexp in
      Ok outcome
    with
    | exn -> Error ("Failed to parse outcome: " ^ Exn.to_string exn)
  in
  Caqti_type.custom ~encode ~decode Caqti_type.string
;;
