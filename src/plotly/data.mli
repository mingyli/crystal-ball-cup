open! Core
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
  [@@deriving jsobject]
end

module Scatter : sig
  type customdata_item = { prediction : string }

  type marker =
    { size : int
    ; color : string array
    }

  type line = { color : string }

  type t =
    { x : float array
    ; y : float array
    ; type_ : string
    ; mode : string
    ; text : string array
    ; customdata : customdata_item array
    ; hovertemplate : string
    ; marker : marker
    ; fill : string option
    ; fillcolor : string option
    ; line : line option
    }
  [@@deriving jsobject]
end

module Violin : sig
  type box = { visible : bool }
  type meanline = { visible : bool }
  type line = { color : string }

  type t =
    { x : float array
    ; type_ : string
    ; name : string
    ; orientation : string
    ; hoverinfo : string
    ; box : box
    ; meanline : meanline
    ; side : string
    ; fillcolor : string
    ; line : line
    ; points : bool
    }
  [@@deriving jsobject]
end

type t =
  | Bar of Bar.t
  | Scatter of Scatter.t
  | Violin of Violin.t

val jsobject_of : t -> t Js.t
val jsobjects_of : t list -> t Js.t Js.js_array Js.t
