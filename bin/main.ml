open! Core

let markdown_command =
  Command.basic ~summary:"Print events in markdown format"
  @@
  let%map_open.Command () = return () in
  fun () ->
    print_endline "# 2025 Crystal Ball Cup\n";
    List.iter Event.all ~f:(fun event ->
      Printf.printf "## %s\n" (Event.short event);
      Printf.printf "%s\n\n" (Event.precise event))
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
