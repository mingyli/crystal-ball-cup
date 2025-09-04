open! Core
open Crystal
open Bonsai_web

type t

val create
  :  events:Event.t list
  -> responses_and_scores:Responses_and_scores.t String.Map.t
  -> t

val component : t -> Vdom.Node.t Computation.t
