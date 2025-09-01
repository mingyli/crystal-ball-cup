open! Core
open Bonsai_web

val component : db_path:string -> Vdom.Node.t Computation.t
