open Js_of_ocaml

type title = { text : string }

let title_to_js title : title Js.t =
  Js.Unsafe.obj [| "text", Js.Unsafe.inject (Js.string title.text) |]
;;

type tickfont = { size : int }

let tickfont_to_js tickfont : tickfont Js.t =
  Js.Unsafe.obj [| "size", Js.Unsafe.inject tickfont.size |]
;;

type yaxis =
  { autorange : string
  ; automargin : bool
  ; tickfont : tickfont
  ; fixedrange : bool
  }

let yaxis_to_js yaxis : yaxis Js.t =
  Js.Unsafe.obj
    [| "autorange", Js.Unsafe.inject (Js.string yaxis.autorange)
     ; "automargin", Js.Unsafe.inject (Js.bool yaxis.automargin)
     ; "tickfont", Js.Unsafe.inject (tickfont_to_js yaxis.tickfont)
     ; "fixedrange", Js.Unsafe.inject (Js.bool yaxis.fixedrange)
    |]
;;

type xaxis =
  { title : string
  ; showticklabels : bool
  ; zeroline : bool
  ; fixedrange : bool
  }

let xaxis_to_js xaxis : xaxis Js.t =
  Js.Unsafe.obj
    [| "title", Js.Unsafe.inject (Js.string xaxis.title)
     ; "showticklabels", Js.Unsafe.inject (Js.bool xaxis.showticklabels)
     ; "zeroline", Js.Unsafe.inject (Js.bool xaxis.zeroline)
     ; "fixedrange", Js.Unsafe.inject (Js.bool xaxis.fixedrange)
    |]
;;

type line =
  { color : string
  ; width : int
  }

let line_to_js line : line Js.t =
  Js.Unsafe.obj
    [| "color", Js.Unsafe.inject (Js.string line.color)
     ; "width", Js.Unsafe.inject line.width
    |]
;;

type shape =
  { type_ : string
  ; x0 : float
  ; y0 : float
  ; x1 : float
  ; y1 : float
  ; line : line
  }

let shape_to_js shape : shape Js.t =
  Js.Unsafe.obj
    [| "type", Js.Unsafe.inject (Js.string shape.type_)
     ; "x0", Js.Unsafe.inject shape.x0
     ; "y0", Js.Unsafe.inject shape.y0
     ; "x1", Js.Unsafe.inject shape.x1
     ; "y1", Js.Unsafe.inject shape.y1
     ; "line", Js.Unsafe.inject (line_to_js shape.line)
    |]
;;

type margin =
  { l : int
  ; r : int
  ; t : int
  ; b : int
  }

let margin_to_js margin : margin Js.t =
  Js.Unsafe.obj
    [| "l", Js.Unsafe.inject margin.l
     ; "r", Js.Unsafe.inject margin.r
     ; "t", Js.Unsafe.inject margin.t
     ; "b", Js.Unsafe.inject margin.b
    |]
;;

type t =
  { title : title
  ; yaxis : yaxis
  ; xaxis : xaxis
  ; shapes : shape list
  ; margin : margin
  ; height : int
  }

let to_js t : t Js.t =
  let shapes_array = Array.of_list (List.map shape_to_js t.shapes) in
  Js.Unsafe.obj
    [| "title", Js.Unsafe.inject (title_to_js t.title)
     ; "yaxis", Js.Unsafe.inject (yaxis_to_js t.yaxis)
     ; "xaxis", Js.Unsafe.inject (xaxis_to_js t.xaxis)
     ; "shapes", Js.Unsafe.inject (Js.array shapes_array)
     ; "margin", Js.Unsafe.inject (margin_to_js t.margin)
     ; "height", Js.Unsafe.inject t.height
    |]
;;
