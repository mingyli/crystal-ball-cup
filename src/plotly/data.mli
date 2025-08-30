open Js_of_ocaml

module Bar : sig
  type textfont = { size : int }

  type line =
    { color : string array
    ; width : int
    }

  type marker =
    { color : string array
    ; line : line
    }

  type t =
    { y : string array
    ; x : float array
    ; type_ : string
    ; orientation : string
    ; text : string array
    ; textposition : string
    ; hoverinfo : string
    ; textfont : textfont
    ; marker : marker
    }
  [@@deriving js]
end

type t = Bar of Bar.t

val to_js : t -> t Js.t
val to_js_array : t list -> t Js.t Js.js_array Js.t
