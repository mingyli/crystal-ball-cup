open! Core
open Crystal
open Bonsai_web

val component : Scores.t String.Map.t -> Vdom.Node.t Computation.t
