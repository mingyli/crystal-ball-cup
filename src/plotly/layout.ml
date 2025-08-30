open Js_of_ocaml

type title = { text : string } [@@deriving js]
type tickfont = { size : int } [@@deriving js]

type yaxis =
  { autorange : string
  ; automargin : bool
  ; tickfont : tickfont
  ; fixedrange : bool
  }
[@@deriving js]

type xaxis =
  { title : string
  ; showticklabels : bool
  ; zeroline : bool
  ; fixedrange : bool
  }
[@@deriving js]

type line =
  { color : string
  ; width : int
  }
[@@deriving js]

type shape =
  { type_ : string
  ; x0 : float
  ; y0 : float
  ; x1 : float
  ; y1 : float
  ; line : line
  }
[@@deriving js]

type margin =
  { l : int
  ; r : int
  ; t : int
  ; b : int
  }
[@@deriving js]

type t =
  { title : title
  ; yaxis : yaxis
  ; xaxis : xaxis
  ; shapes : shape list
  ; margin : margin
  ; height : int
  }
[@@deriving js]
