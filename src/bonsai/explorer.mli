open! Core
open Bonsai_web.Cont

val component
  :  db_path:string
  -> initial_query:string
  -> Bonsai.graph
  -> Vdom.Node.t Bonsai.t
