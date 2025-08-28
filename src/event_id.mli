open! Core

type t [@@deriving compare, sexp]

val of_int : int -> t
val caqti_type : t Caqti_type.t
val to_string : t -> string

include Comparable.S with type t := t

module Map : sig
  type key := t
  type 'a t = (key, 'a, comparator_witness) Core.Map.t

  include module type of Map with type 'a t := 'a t
end
