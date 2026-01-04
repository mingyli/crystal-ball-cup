open! Core
open Bonsai_web.Cont

val component
  :  db:Crystal_sqljs.Db.t Bonsai.t
  -> initial_query:string
  -> ?interactive:bool
  -> Bonsai.graph
  -> Vdom.Node.t Bonsai.t
