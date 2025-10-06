open! Core

type t [@@deriving compare, equal, sexp]

val create : ?link:string -> date:Date.t -> description:string -> unit -> t
val link : t -> string option
val date : t -> Date.t
val description : t -> string
