open! Core

type title = { text : string } [@@deriving jsobject]
type tickfont = { size : int } [@@deriving jsobject]

type yaxis =
  { autorange : string option [@jsobject.drop_none]
  ; automargin : bool option [@jsobject.drop_none]
  ; tickfont : tickfont option [@jsobject.drop_none]
  ; fixedrange : bool
  ; range : float list option [@jsobject.drop_none]
  }
[@@deriving jsobject]

type xaxis =
  { title : string
  ; showticklabels : bool
  ; zeroline : bool
  ; fixedrange : bool
  ; range : float list option [@jsobject.drop_none]
  ; tickvals : float list option [@jsobject.drop_none]
  ; ticktext : string list option [@jsobject.drop_none]
  }
[@@deriving jsobject]

type line =
  { color : string
  ; width : int
  }
[@@deriving jsobject]

type shape =
  { type_ : string [@jsobject.key "type"]
  ; x0 : float
  ; y0 : float
  ; x1 : float
  ; y1 : float
  ; line : line
  }
[@@deriving jsobject]

type margin =
  { l : int
  ; r : int
  ; t : int
  ; b : int
  }
[@@deriving jsobject]

type t =
  { title : title
  ; yaxis : yaxis
  ; xaxis : xaxis
  ; shapes : shape list
  ; margin : margin
  ; height : int
  ; showlegend : bool
  }
[@@deriving jsobject]
