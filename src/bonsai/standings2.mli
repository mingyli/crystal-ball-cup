open! Core
open Crystal
open Bonsai_web.Cont

type t

val create : Event.t list -> Scores.t String.Map.t -> [ `Date | `Id ] Bonsai.t -> t
val component : t -> Bonsai.graph -> Vdom.Node.t Bonsai.t
