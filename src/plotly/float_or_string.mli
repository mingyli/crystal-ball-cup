open! Core

type t =
  | Float of float
  | String of string
[@@deriving jsobject_of]
