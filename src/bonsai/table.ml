open! Core
module Bonsai = Bonsai.Cont
open! Bonsai_web.Cont
open Bonsai.Let_syntax
module Table = Bonsai_web_ui_partial_render_table

(* A record type for our row data. *)
module Row = struct
  type t =
    { name : string
    ; age : int
    ; favorite_color : string
    }
  [@@deriving fields]
end

(* A variant for the column identifiers. *)
module Col_id = struct
  type t =
    | Name
    | Age
    | Favorite_color
  [@@deriving sexp, compare, equal, enumerate]
end

let component graph =
  (* Create a static map of dummy data. *)
  let data =
    let data =
      List.init 1000 ~f:(fun i ->
        ( i
        , { Row.name = sprintf "Person %d" i
          ; age = 20 + (i % 50)
          ; favorite_color =
              (match i % 3 with
               | 0 -> "Blue"
               | 1 -> "Green"
               | _ -> "Red")
          } ))
    in
    Int.Map.of_alist_exn data
  in
  (* Define the table columns using [Dynamic_cells]. This allows each cell to be its own computation. *)
  let columns =
    Table.Basic.Columns.Dynamic_columns.(
      lift
        (return
           [ column
               ~header:(fun _ -> Vdom.Node.text "Name")
               ~sort:(fun (_, a) (_, b) -> String.compare (Row.name a) (Row.name b))
               ~cell:(fun ~key:_ ~data -> Vdom.Node.text (Row.name data))
               ()
           ; column
               ~header:(fun _ -> Vdom.Node.text "Age")
               ~sort:(fun (_, a) (_, b) -> Int.compare (Row.age a) (Row.age b))
               ~cell:(fun ~key:_ ~data -> Vdom.Node.text (Int.to_string (Row.age data)))
               ()
           ; column
               ~header:(fun _ -> Vdom.Node.text "Favorite Color")
               ~sort:(fun (_, a) (_, b) ->
                 String.compare (Row.favorite_color a) (Row.favorite_color b))
               ~cell:(fun ~key:_ ~data -> Vdom.Node.text (Row.favorite_color data))
               ()
           ]))
  in
  (* Instantiate the table component. *)
  let table =
    Table.Basic.component
      (module Int) (* The comparator for the key of the map *)
      ~focus:Table.Basic.Focus.None
      ~row_height:(return (`Px 30))
      ~columns
      (return data)
      graph
  in
  (* The component returns a Vdom.Node.t Computation.t. We extract the [view] from the table result. *)
  let%map { view; _ } = table in
  view
;;
