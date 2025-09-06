open! Core
module Bonsai = Bonsai.Cont
open Bonsai_web.Cont

val component : Bonsai.graph -> Vdom.Node.t Bonsai.t
