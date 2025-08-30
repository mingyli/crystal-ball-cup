open Js_of_ocaml

type t = { display_mode_bar : bool }

val to_js : t -> t Js.t
