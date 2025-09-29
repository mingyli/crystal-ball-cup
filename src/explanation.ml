open! Core

type t = { date : Date.t; description : string; link : string option; } 
[@@deriving compare, equal, sexp, fields]

let create ?link ~date ~description () =
  { date; description; link }
