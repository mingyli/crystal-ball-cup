open! Core
module Bonsai = Bonsai.Cont
open Bonsai.Let_syntax
open Bonsai_web.Cont
open Js_of_ocaml

let execute_query db query set_results =
  let open Vdom in
  try
    let tables = Crystal_sqljs.Db.exec db query in
    let results =
      List.map tables ~f:(fun table ->
        let columns = Crystal_sqljs.Db.Table.columns table in
        let rows = Crystal_sqljs.Db.Table.rows table in
        let header_row =
          Node.tr
          @@ List.map columns ~f:(fun column ->
            Node.th
              ~attrs:
                [ {%css|
            background-color: #f2f2f2;
            border: 1px solid #ddd;
            text-align: left;
            padding: 4px;
            font-size: 0.8em;
            font-family: monospace;
            |}
                ]
              [ Node.text column ])
        in
        let table_rows =
          List.map rows ~f:(fun row ->
            let row =
              List.map row ~f:(fun value ->
                Node.td
                  ~attrs:
                    [ {%css|
            border: 1px solid #ddd;
            text-align: left;
            padding: 4px;
            font-size: 0.8em;
            font-family: monospace;
            |}
                    ]
                  [ Node.text value ])
            in
            Node.tr
              ~attrs:
                [ {%css|
            &:nth-child(even) {
                background-color: #f9f9f9;
            }

            &:nth-child(odd) {
                background-color: #ffffff;
            }

            &:hover {
                background-color: #e9ecef;
            }
            |}
                ]
              row)
        in
        Node.table
          ~attrs:
            [ {%css|
            margin: auto;
            border-collapse: collapse;
            margin-top: 10px;
            |}
            ]
          (header_row :: table_rows))
    in
    set_results results
  with
  | exn ->
    let error =
      Node.pre
        ~attrs:[ {%css|color: red;|} ]
        [ Node.text (exn |> Error.of_exn |> Error.to_string_hum) ]
    in
    set_results [ error ]
;;

let component ~db_path ~initial_query graph =
  let db, set_db = Bonsai.state None graph in
  let query, set_query = Bonsai.state initial_query graph in
  let results, set_results = Bonsai.state [] graph in
  let () =
    Bonsai.Edge.lifecycle
      ~on_activate:
        (let%map set_db = set_db in
         let (_promise : unit Promise.t) =
           let open Promise.Syntax in
           let* db' = Crystal_sqljs.Db.load ~db_path in
           (* We need the expert api here because we can't otherwise
              schedule the set_db effect from within this promise. *)
           Effect.Expert.handle_non_dom_event_exn (set_db (Some db'));
           Promise.resolve ()
         in
         Effect.Ignore)
      graph
  in
  let () =
    Bonsai.Edge.on_change
      db
      ~equal:[%equal: Crystal_sqljs.Db.t option]
      ~callback:
        (let%map set_results = set_results
         and query = query in
         function
         | None -> Effect.print_s [%message "Database not loaded yet"]
         | Some db -> execute_query db query set_results)
      graph
  in
  let%arr query = query
  and set_query = set_query
  and db = db
  and results = results
  and set_results = set_results in
  let open Vdom in
  match db with
  | None -> Node.div [ Node.text "Database not loaded yet" ]
  | Some db ->
    Node.div
      [ Node.textarea
          ~attrs:
            [ Attr.on_input (fun _event -> set_query)
            ; Attr.on_keydown (fun event ->
                if
                  Js.to_bool event##.ctrlKey
                  && [%equal: string option]
                       (Some "Enter")
                       (event##.key |> Js.Optdef.to_option |> Option.map ~f:Js.to_string)
                then (
                  Dom.preventDefault event;
                  execute_query db query set_results)
                else Effect.Ignore)
            ; {%css|
          margin: auto;
          width: 100%;
          height: 50px;
          font-family: monospace;
          |}
            ]
          [ Node.text query ]
      ; Node.button
          ~attrs:
            [ {%css|
          font_family: "monospace"
          |}
            ; Attr.on_click (fun _event -> execute_query db query set_results)
            ]
          [ Node.text "Run (ctrl+enter)" ]
      ; Node.div results
      ]
;;
