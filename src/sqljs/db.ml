open! Core
open Js_of_ocaml

module Table = struct
  type t =
    < columns : Js.js_string Js.t Js.js_array Js.t Js.readonly_prop
    ; values : Js.Unsafe.any Js.js_array Js.t Js.js_array Js.t Js.readonly_prop >
      Js.t

  let columns t = t##.columns |> Js.to_array |> Array.to_list |> List.map ~f:Js.to_string

  let any_to_string_fallback (x : Js.Unsafe.any) : string =
    Js.to_string (Js.Unsafe.fun_call (Js.Unsafe.pure_js_expr "String") [| x |])
  ;;

  let rows t =
    t##.values
    |> Js.to_array
    |> Array.to_list
    |> List.map ~f:(fun row ->
      row |> Js.to_array |> Array.to_list |> List.map ~f:any_to_string_fallback)
  ;;
end

type t = < exec : Js.js_string Js.t -> Table.t Js.js_array Js.t Js.meth > Js.t

let fetch (url : string) : 'a Js.t =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "fetch") [| Js.Unsafe.inject (Js.string url) |]
;;

let of_js_promise (p : 'a Js.t) : 'a Promise.t =
  Promise.make (fun ~resolve ~reject:_ ->
    let then_ (x : 'a) = resolve x in
    let catch (_e : exn) = () in
    (* Ignore errors for now *)
    (Js.Unsafe.coerce p)##then_ (Js.wrap_callback then_) (Js.wrap_callback catch))
;;

let load ~url =
  let open Promise.Syntax in
  let config : Sqljs.Config.t =
    { locate_file =
        (fun file ->
          [%string "https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/%{file}"])
    }
  in
  let* sql_constructor = of_js_promise (Sqljs.invoke Sqljs.init_sql_js config) in
  let* response = of_js_promise (fetch url) in
  let* buffer = of_js_promise response##arrayBuffer in
  let db_uint8_array = new%js Typed_array.uint8Array_fromBuffer buffer in
  Firebug.console##log sql_constructor;
  let constr = sql_constructor##.Database in
  let db = new%js constr db_uint8_array in
  Promise.return db
;;

let exec t query =
  let results = t##exec (Js.string query) in
  results |> Js.to_array |> Array.to_list
;;
