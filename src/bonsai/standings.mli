open! Core
open Crystal
open Bonsai_web.Cont

val component
  :  start_date:Date.t
  -> end_date:Date.t
  -> Event.t list
  -> Scores.t String.Map.t
  -> Bonsai.graph
  -> Vdom.Node.t Bonsai.t
