open Js_of_ocaml

type title = { text : string }
type tickfont = { size : int }

type yaxis =
  { autorange : string
  ; automargin : bool
  ; tickfont : tickfont
  ; fixedrange : bool
  }

type xaxis =
  { title : string
  ; showticklabels : bool
  ; zeroline : bool
  ; fixedrange : bool
  }

type line =
  { color : string
  ; width : int
  }

type shape =
  { type_ : string
  ; x0 : float
  ; y0 : float
  ; x1 : float
  ; y1 : float
  ; line : line
  }

type margin =
  { l : int
  ; r : int
  ; t : int
  ; b : int
  }

type t =
  { title : title
  ; yaxis : yaxis
  ; xaxis : xaxis
  ; shapes : shape list
  ; margin : margin
  ; height : int
  }
[@@deriving js]
