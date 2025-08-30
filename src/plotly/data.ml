open Js_of_ocaml

module Bar = struct
  type textfont = { size : int } [@@deriving js]

  type line =
    { color : string array
    ; width : int
    }
  [@@deriving js]

  type marker =
    { color : string array
    ; line : line
    }
  [@@deriving js]

  type t =
    { y : string array
    ; x : float array
    ; type_ : string [@key "type"]
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

let to_js = function
  | Bar bar -> Bar.to_js bar |> Js.Unsafe.coerce
;;

let to_js_array (ts : t list) : t Js.t Js.js_array Js.t =
  let js_objects = Array.of_list (List.map to_js ts) in
  Js.array js_objects
;;
