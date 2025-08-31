open! Core
open Bonsai_web

val component : db_url:string -> Vdom.Node.t Computation.t
