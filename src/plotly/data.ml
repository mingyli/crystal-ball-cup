open! Core
open Js_of_ocaml

module Bar = struct
  type textfont = { size : int } [@@deriving jsobject]

  type line =
    { color : string array
    ; width : int
    }
  [@@deriving jsobject]

  type marker =
    { color : string array
    ; line : line
    }
  [@@deriving jsobject]

  type t =
    { y : string array
    ; x : float array
    ; type_ : string [@jsobject.key "type"]
    ; orientation : string
    ; text : string array
    ; textposition : string
    ; hoverinfo : string
    ; textfont : textfont
    ; marker : marker
    }
  [@@deriving jsobject]
end

module Scatter = struct
  type customdata_item = { prediction : string } [@@deriving jsobject]

  type marker =
    { size : int
    ; color : string array
    }
  [@@deriving jsobject]

  type line = { color : string } [@@deriving jsobject]

  type t =
    { x : float array
    ; y : float array
    ; type_ : string [@jsobject.key "type"]
    ; mode : string
    ; text : string array
    ; customdata : customdata_item array
    ; hovertemplate : string
    ; marker : marker
    ; fill : string option [@jsobject.drop_none]
    ; fillcolor : string option [@jsobject.drop_none]
    ; line : line option [@jsobject.drop_none]
    }
  [@@deriving jsobject]
end

module Violin = struct
  type box = { visible : bool } [@@deriving jsobject]
  type meanline = { visible : bool } [@@deriving jsobject]
  type line = { color : string } [@@deriving jsobject]

  type t =
    { x : float array
    ; type_ : string [@jsobject.key "type"]
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

let jsobject_of = function
  | Bar bar -> Bar.jsobject_of bar |> Js.Unsafe.coerce
  | Scatter scatter -> Scatter.jsobject_of scatter |> Js.Unsafe.coerce
  | Violin violin -> Violin.jsobject_of violin |> Js.Unsafe.coerce
;;

let jsobjects_of (ts : t list) : t Js.t Js.js_array Js.t =
  let js_objects = Array.of_list (List.map ~f:jsobject_of ts) in
  Js.array js_objects
;;
