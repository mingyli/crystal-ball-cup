open! Core

type t [@@deriving compare, sexp, yojson_of]

val of_int : int -> t
val to_string : t -> string

include Comparable.S with type t := t

module Map : sig
  type key := t
  type 'a t = (key, 'a, comparator_witness) Core.Map.t [@@deriving yojson_of]

  include module type of Map with type 'a t := 'a t
end
