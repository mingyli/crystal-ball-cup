open Js_of_ocaml

module Config = struct
  type t = { display_mode_bar : bool }

  let to_js t : t Js.t =
    Js.Unsafe.obj [| "displayModeBar", Js.Unsafe.inject (Js.bool t.display_mode_bar) |]
  ;;
end

type plotly =
  < newPlot :
      Dom_html.divElement Js.t
      -> Data.t Js.t Js.js_array Js.t
      -> Layout.t Js.t
      -> Config.t Js.t
      -> unit Js.meth >

let plotly : plotly Js.t = Js.Unsafe.pure_js_expr "Plotly"

let create div data layout config =
  plotly##newPlot div (Data.to_js_array data) (Layout.to_js layout) (Config.to_js config)
;;
