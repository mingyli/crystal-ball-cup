open! Core
module Bonsai = Bonsai.Cont
open Bonsai.Let_syntax
open Bonsai_web.Cont
open! Crystal
open Crystal_bonsai

let all graph =
  let explorer =
    Explorer.component
      ~db_path:"./crystal.db"
      ~initial_query:
        {|SELECT
  name, sql
FROM
  sqlite_master
WHERE
  type IN ('table', 'view')|}
      graph
  in
  let%arr explorer = explorer in
  let open Vdom in
  Node.div [ Node.h2 [ Node.text "Events" ]; Node.h2 [ Node.text "Explorer" ]; explorer ]
;;

let () = Bonsai_web.Start.start ~bind_to_element_with_id:"app" all
