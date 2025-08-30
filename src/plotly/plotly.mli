open Js_of_ocaml

type t =
  < newPlot :
      Dom_html.divElement Js.t
      -> Data.t Js.t Js.js_array Js.t
      -> Layout.t Js.t
      -> Config.t Js.t
      -> unit Js.meth >

val plotly : t Js.t
val create : Dom_html.divElement Js.t -> Data.t list -> Layout.t -> Config.t -> unit
