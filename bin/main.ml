open! Core

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

let command =
  Command.group
    ~summary:"Crystal Ball Cup"
    [ "markdown", markdown_command; "sexp", sexp_command ]
;;

let () = Command.run command
