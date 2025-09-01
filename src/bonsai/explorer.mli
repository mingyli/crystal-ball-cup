open! Core
open Bonsai_web

val component : db_path:string -> initial_query:string -> Vdom.Node.t Computation.t
