open! Core
module Bonsai = Bonsai.Cont
open Bonsai_web.Cont
open Crystal

val component
  :  collection:Collection.t
  -> responses_and_scores:Responses_and_scores.t String.Map.t
  -> Bonsai.graph
  -> Vdom.Node.t Bonsai.t
