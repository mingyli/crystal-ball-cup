open Js_of_ocaml

module Bar = struct
  type textfont = { size : int }

  let textfont_to_js textfont : textfont Js.t =
    Js.Unsafe.obj [| "size", Js.Unsafe.inject textfont.size |]
  ;;

  type line =
    { color : string array
    ; width : int
    }

  let line_to_js line : line Js.t =
    let color_array = Array.map (fun c -> Js.string c) line.color in
    Js.Unsafe.obj
      [| "color", Js.Unsafe.inject (Js.array color_array)
       ; "width", Js.Unsafe.inject line.width
      |]
  ;;

  type marker =
    { color : string array
    ; line : line
    }

  let marker_to_js marker : marker Js.t =
    let color_array = Array.map (fun c -> Js.string c) marker.color in
    Js.Unsafe.obj
      [| "color", Js.Unsafe.inject (Js.array color_array)
       ; "line", Js.Unsafe.inject (line_to_js marker.line)
      |]
  ;;

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

  let to_js t : t Js.t =
    let y_array = Array.map (fun s -> Js.string s) t.y in
    let text_array = Array.map (fun s -> Js.string s) t.text in
    Js.Unsafe.obj
      [| "y", Js.Unsafe.inject (Js.array y_array)
       ; "x", Js.Unsafe.inject (Js.array t.x)
       ; "type", Js.Unsafe.inject (Js.string t.type_)
       ; "orientation", Js.Unsafe.inject (Js.string t.orientation)
       ; "text", Js.Unsafe.inject (Js.array text_array)
       ; "textposition", Js.Unsafe.inject (Js.string t.textposition)
       ; "hoverinfo", Js.Unsafe.inject (Js.string t.hoverinfo)
       ; "textfont", Js.Unsafe.inject (textfont_to_js t.textfont)
       ; "marker", Js.Unsafe.inject (marker_to_js t.marker)
      |]
  ;;
end

type t = Bar of Bar.t

let to_js t : t Js.t =
  match t with
  | Bar bar -> Bar.to_js bar |> Js.Unsafe.coerce
;;

let to_js_array (ts : t list) : t Js.t Js.js_array Js.t =
  let js_objects = Array.of_list (List.map to_js ts) in
  Js.array js_objects
;;
