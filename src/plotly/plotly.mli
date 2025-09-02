open Js_of_ocaml

type t

val plotly : t Js.t
val create : Dom_html.divElement Js.t -> Data.t list -> Layout.t -> Config.t -> unit
val react : Dom_html.divElement Js.t -> Data.t list -> Layout.t -> Config.t -> unit
