open! Core
open Js_of_ocaml

type t = 
  { display_mode_bar : bool
  ; displaylogo : bool
  }

val jsobject_of : t -> t Js.t
