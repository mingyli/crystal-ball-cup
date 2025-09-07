open! Core
open Crystal

module Make (Collection : Collection.S) = struct
  let markdown_command =
    Command.basic ~summary:"Print events in markdown format"
    @@
    let%map_open.Command () = return () in
    fun () ->
      print_endline "# Events\n";
      List.iteri Collection.all ~f:(fun i event ->
        print_endline [%string "## %{i+1#Int}. %{Event.short event}"];
        print_endline [%string "%{Event.precise event}\n"])
  ;;

  let sexp_command =
    Command.basic ~summary:"Print events in sexp format"
    @@
    let%map_open.Command () = return () in
    fun () ->
      List.iter Collection.all ~f:(fun event ->
        print_s ~mach:() [%sexp (event : Event.t)])
  ;;

  let responses_and_scores_command =
    Command.basic ~summary:"Print responses and scores"
    @@
    let%map_open.Command () = return ()
    and responses_file =
      flag "responses" (required Filename_unix.arg_type) ~doc:"FILE responses csv file"
    in
    fun () ->
      let responses = Responses.of_csv (In_channel.read_all responses_file) in
      let responses_and_scores =
        Map.map responses ~f:(Responses_and_scores.of_responses (module Collection))
      in
      print_s [%sexp (responses_and_scores : Responses_and_scores.t String.Map.t)]
  ;;

  let create_db_command =
    Command.basic ~summary:"Create and populate a sqlite database"
    @@
    let%map_open.Command () = return ()
    and output_file =
      flag
        "output"
        (required Filename_unix.arg_type)
        ~doc:"FILE output sqlite database file"
    and responses_file =
      flag "responses" (required Filename_unix.arg_type) ~doc:"FILE responses csv file"
    in
    fun () ->
      let responses = Responses.of_csv (In_channel.read_all responses_file) in
      let scores =
        Map.map responses ~f:(fun responses ->
          Scores.create (module Collection) responses)
      in
      let module Db = Crystal_sqlite.Db in
      let db = Db.create ~output_file in
      Db.with_connection db ~f:(fun conn ->
        let%bind.Or_error () = Db.Connection.make_events conn (module Collection) in
        let%bind.Or_error () = Db.Connection.make_responses conn responses in
        let%bind.Or_error () = Db.Connection.make_scores conn scores in
        let%bind.Or_error () = Db.Connection.make_responses_and_scores conn in
        Ok ())
      |> Or_error.ok_exn
  ;;

  let command =
    Command.group
      ~summary:[%string "Crystal Ball Cup %{Collection.name}"]
      [ "markdown", markdown_command
      ; "sexp", sexp_command
      ; "responses-and-scores", responses_and_scores_command
      ; "create-db", create_db_command
      ]
  ;;
end

let command =
  let collections : Collection.t list = [ (module Crystal_collections.M2025) ] in
  Command.group ~summary:"Crystal Ball Cup"
  @@ List.map collections ~f:(fun (module Collection) ->
    let module Commands = Make (Collection) in
    Collection.name, Commands.command)
;;

let () = Command_unix.run command
