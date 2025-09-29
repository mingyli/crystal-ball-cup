open! Core

type t = { date : Date.t; description : string; link : string option; } 

[@@deriving compare, equal, sexp]

val create : date:Date.t -> description:string -> ?link:string -> unit -> t
val link : t -> string option
val date : t -> Date.t
val description : t -> string
