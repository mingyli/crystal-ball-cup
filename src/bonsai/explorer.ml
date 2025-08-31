open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Js_of_ocaml

let component ~db_url =
  let db = Set_once.create () in
  let%sub query, set_query =
    Bonsai.state "SELECT name, sql FROM sqlite_master WHERE type = 'table';"
  in
  let%sub results, set_results = Bonsai.state [] in
  let%sub () =
    Bonsai.Edge.lifecycle
      ()
      ~on_activate:
        (Value.return
           (Ui_effect.of_sync_fun
              (fun () ->
                 let (_promise : unit Promise.t) =
                   let open Promise.Syntax in
                   let* db' = Crystal_sqljs.Db.load ~url:db_url in
                   Set_once.set_exn db [%here] db';
                   Promise.resolve ()
                 in
                 ())
              ()))
  in
  let%arr query = query
  and set_query = set_query
  and results = results
  and set_results = set_results in
  let open Vdom in
  let execute_query () =
    let db = Set_once.get_exn db [%here] in
    Firebug.console##log query;
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
  in
  Node.div
    [ Node.h2 [ Node.text "Explorer" ]
    ; Node.textarea
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
                execute_query ())
              else Vdom.Effect.Ignore)
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
          ; Attr.on_click (fun _event -> execute_query ())
          ]
        [ Node.text "Run (ctrl+enter)" ]
    ; Node.div results
    ]
;;
