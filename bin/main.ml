open! Core

let command =
  Command.basic ~summary:"Crystal Ball Cup"
  @@
  let%map_open.Command () = return () in
  fun () -> List.iter Event.all ~f:(fun event -> print_s [%sexp (event : Event.t)])
;;

let () = Command.run command
