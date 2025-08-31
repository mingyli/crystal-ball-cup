open! Js_of_ocaml

module Config = struct
  type t = { locate_file : string -> string }

  let to_js t =
    let locate_file file = file |> Js.to_string |> t.locate_file |> Js.string in
    Js.Unsafe.obj [| "locateFile", Js.Unsafe.inject (Js.wrap_callback locate_file) |]
  ;;
end

type t = < > Js.t

let init_sql_js : t = Js.Unsafe.global##.initSqlJs
let invoke t (config : Config.t) = Js.Unsafe.fun_call t [| Config.to_js config |]
