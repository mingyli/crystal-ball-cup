open! Core
open Crystal
open Bonsai_web.Cont

val component : Scores.t String.Map.t -> Bonsai.graph -> Vdom.Node.t Bonsai.t
