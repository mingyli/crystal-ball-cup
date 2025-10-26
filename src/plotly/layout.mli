open! Core
open Js_of_ocaml

type title = { text : string }
type tickfont = { size : int }

type yaxis =
  { autorange : string option
  ; automargin : bool option
  ; tickfont : tickfont option
  ; fixedrange : bool
  ; range : float list option
  }

type xaxis =
  { title : string
  ; showticklabels : bool
  ; zeroline : bool
  ; fixedrange : bool
  ; range : Float_or_string.t list option
  ; tickvals : float list option
  ; ticktext : string list option
  ; type_ : string option
  ; autorange : bool option
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
  ; showlegend : bool
  }
[@@deriving jsobject_of]

val jsobject_of : t -> t Js.t
