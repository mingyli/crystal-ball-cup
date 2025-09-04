open! Core
open Js_of_ocaml

type t = { display_mode_bar : bool }

val jsobject_of : t -> t Js.t
