open! Core
open Js_of_ocaml

type t =
  | Float of float
  | String of string

let jsobject_of = function
  | Float f -> Js.number_of_float f |> Js.Unsafe.coerce
  | String s -> Js.string s |> Js.Unsafe.coerce
;;
