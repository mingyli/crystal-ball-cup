open! Core
open Crystal

let markdown_command =
  Command.basic ~summary:"Print events in markdown format"
  @@
  let%map_open.Command () = return () in
  fun () ->
    print_endline "# Events\n";
    List.iteri Event.all ~f:(fun i event ->
      print_endline [%string "## %{i+1#Int}. %{Event.short event}"];
      print_endline [%string "%{Event.precise event}\n"])
;;

let sexp_command =
  Command.basic ~summary:"Print events in sexp format"
  @@
  let%map_open.Command () = return () in
  fun () ->
    List.iter Event.all ~f:(fun event -> print_s ~mach:() [%sexp (event : Event.t)])
;;

let json_command =
  Command.basic ~summary:"Print events in json format"
  @@
  let%map_open.Command () = return () in
  fun () ->
    let yojson = `List (List.map Event.all ~f:Event.to_yojson) in
    print_endline (Yojson.Safe.pretty_to_string yojson)
;;

let command =
  Command.group
    ~summary:"Crystal Ball Cup"
    [ "markdown", markdown_command; "sexp", sexp_command; "json", json_command ]
;;

let () = Command.run command
