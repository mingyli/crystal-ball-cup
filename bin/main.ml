open! Core
open Crystal

module Make (Collection : Event.Collection) = struct
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

  let json_command =
    Command.basic ~summary:"Print events in json format"
    @@
    let%map_open.Command () = return () in
    fun () ->
      let yojson = `List (List.map Collection.all ~f:[%yojson_of: Event.t]) in
      print_endline (Yojson.Safe.pretty_to_string yojson)
  ;;

  let scores_command =
    Command.basic ~summary:"Print scores"
    @@
    let%map_open.Command () = return ()
    and responses_file =
      flag "responses" (required Filename.arg_type) ~doc:"FILE responses csv file"
    in
    fun () ->
      let responses = Response.of_csv (In_channel.read_all responses_file) in
      let user_event_scores = String.Table.create () in
      List.iter responses ~f:(fun (response : Response.t) ->
        let user = Response.user response in
        List.iter Collection.all ~f:(fun (event : Event.t) ->
          let event_id = Event.id event in
          let probability = Response.probability response ~event_id in
          let score = Event.score event ~probability in
          Hashtbl.update user_event_scores user ~f:(function
            | Some scores_map -> Map.add_exn scores_map ~key:event_id ~data:score
            | None -> Int.Map.singleton event_id score)));
      let user_event_scores = String.Map.of_hashtbl_exn user_event_scores in
      let all_user_scores = Scores.of_user_event_scores user_event_scores in
      let json_output =
        `Assoc
          (Map.to_alist all_user_scores
           |> List.map ~f:(fun (user, scores_data) ->
             user, [%yojson_of: Scores.t] scores_data))
      in
      print_endline (Yojson.Safe.pretty_to_string json_output)
  ;;

  let command =
    Command.group
      ~summary:"Crystal Ball Cup"
      [ "markdown", markdown_command
      ; "sexp", sexp_command
      ; "json", json_command
      ; "scores", scores_command
      ]
  ;;
end

let command =
  let collections : (string * (module Event.Collection)) list =
    [ "2025", (module M2025.Events) ]
  in
  Command.group ~summary:"Crystal Ball Cup"
  @@ List.map collections ~f:(fun (name, (module Collection)) ->
    let module Commands = Make (Collection) in
    name, Commands.command)
;;

let () = Command.run command
