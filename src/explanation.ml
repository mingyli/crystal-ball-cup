open! Core

type t = { date : Date.t; description : string; link : string option; } 
[@@deriving compare, equal, sexp, fields]

let create ~date ~description ?link () =
  { date; description; link }
