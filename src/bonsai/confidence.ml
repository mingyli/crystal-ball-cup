open! Core
module Bonsai = Bonsai.Cont
open Bonsai.Let_syntax
open Bonsai_web.Cont
open Crystal

let component ~collection ~responses_and_scores _graph =
  let _responses_and_scores = Map.find_exn responses_and_scores "mingyli34@gmail.com" in
  let outcomes =
    collection
    |> Collection.all
    |> List.map ~f:Event.outcome
    |> List.map ~f:Outcome.to_float
    |> List.to_array
  in
  let%arr () = return () in
  let open Vdom in
  Node.div
    [ Node.div
        (outcomes
         |> List.of_array
         |> List.map ~f:(fun outcome -> Node.div [ Node.text (Float.to_string outcome) ])
        )
    ]
;;
