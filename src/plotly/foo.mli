open Js_of_ocaml

module Config : sig
  type t = { display_mode_bar : bool }
end

type plotly =
  < newPlot :
      Dom_html.divElement Js.t
      -> Data.t Js.t Js.js_array Js.t
      -> Layout.t Js.t
      -> Config.t Js.t
      -> unit Js.meth >

val plotly : plotly Js.t
val create : Dom_html.divElement Js.t -> Data.t list -> Layout.t -> Config.t -> unit
