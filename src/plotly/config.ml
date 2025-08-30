open Js_of_ocaml

type t = { display_mode_bar : bool }

let to_js t : t Js.t =
  Js.Unsafe.obj [| "displayModeBar", Js.Unsafe.inject (Js.bool t.display_mode_bar) |]
;;
