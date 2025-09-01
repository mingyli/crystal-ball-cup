open! Core
open Js_of_ocaml

module Config : sig
  type t = { locate_file : string -> string }
end

type t

(** Returns a promise that resolves to a SQL.js instance *)
val init : Config.t -> _ Js.t
