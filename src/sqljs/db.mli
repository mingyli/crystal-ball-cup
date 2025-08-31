open! Js_of_ocaml

type t

val load : url:string -> t Promise.t

module Table : sig
  type t

  val columns : t -> string list
  val rows : t -> string list list
end

val exec : t -> string -> Table.t list
