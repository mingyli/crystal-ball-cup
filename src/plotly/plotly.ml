open Js_of_ocaml

type t =
  < newPlot :
      Dom_html.divElement Js.t
      -> Data.t Js.t Js.js_array Js.t
      -> Layout.t Js.t
      -> Config.t Js.t
      -> unit Js.meth
  ; react :
      Dom_html.divElement Js.t
      -> Data.t Js.t Js.js_array Js.t
      -> Layout.t Js.t
      -> Config.t Js.t
      -> unit Js.meth >

let plotly : t Js.t = Js.Unsafe.pure_js_expr "Plotly"

let create div data layout config =
  plotly##newPlot
    div
    (Data.jsobjects_of data)
    (Layout.jsobject_of layout)
    (Config.jsobject_of config)
;;

let react div data layout config =
  plotly##react
    div
    (Data.jsobjects_of data)
    (Layout.jsobject_of layout)
    (Config.jsobject_of config)
;;
