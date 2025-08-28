open! Core
open Crystal
open Bonsai_web

val events : Collection.t -> Vdom.Node.t Computation.t
val standings : Collection.t -> Scores.t String.Map.t -> Vdom.Node.t Computation.t
