open! Core
open Js_of_ocaml

module Config : sig
  type t = { locate_file : string -> string }
end

type t

val init_sql_js : t
val invoke : t -> Config.t -> _ Js.t
