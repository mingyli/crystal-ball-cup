open Js_of_ocaml

type t = { display_mode_bar : bool [@js_key "displayModeBar"] } [@@deriving js]
