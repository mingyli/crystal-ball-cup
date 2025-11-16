open! Core
module Bonsai = Bonsai.Cont
open Bonsai_web.Cont
open Crystal

val component
  :  collection:Collection.t
  -> responses:Responses.t String.Map.t
  -> Bonsai.graph
  -> Vdom.Node.t Bonsai.t
