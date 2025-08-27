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

  let json_command =
    Command.basic ~summary:"Print events in json format"
    @@
    let%map_open.Command () = return () in
    fun () ->
      let yojson = `List (List.map Collection.all ~f:[%yojson_of: Event.t]) in
      print_endline (Yojson.Safe.pretty_to_string yojson)
  ;;

  let responses_and_scores_command =
    Command.basic ~summary:"Print responses and scores"
    @@
    let%map_open.Command () = return ()
    and responses_file =
      flag "responses" (required Filename.arg_type) ~doc:"FILE responses csv file"
    in
    fun () ->
      let responses = Responses.of_csv (In_channel.read_all responses_file) in
      let scores =
        Map.map responses ~f:(fun responses ->
          Scores.create (module Collection) responses)
      in
      let responses_and_scores =
        Map.merge responses scores ~f:(fun ~key:respondent -> function
          | `Left responses ->
            raise_s
              [%message
                "No scores found for respondent"
                  (respondent : string)
                  (responses : Responses.t)]
          | `Right scores ->
            raise_s
              [%message
                "No responses provided for respondent"
                  (respondent : string)
                  (scores : Scores.t)]
          | `Both (responses, scores) ->
            Some (Responses_and_scores.create responses scores))
      in
      let json_output =
        `Assoc
          (Map.to_alist responses_and_scores
           |> List.map ~f:(fun (respondent, responses_and_scores) ->
             respondent, [%yojson_of: Responses_and_scores.t] responses_and_scores))
      in
      print_endline (Yojson.Safe.pretty_to_string json_output)
  ;;

  let command =
    Command.group
      ~summary:[%string "Crystal Ball Cup %{Collection.name}"]
      [ "markdown", markdown_command
      ; "sexp", sexp_command
      ; "json", json_command
      ; "responses-and-scores", responses_and_scores_command
      ]
  ;;
end

let command =
  let collections : (module Collection.S) list = [ (module Collections.M2025) ] in
  Command.group ~summary:"Crystal Ball Cup"
  @@ List.map collections ~f:(fun (module Collection) ->
    let module Commands = Make (Collection) in
    Collection.name, Commands.command)
;;

let () = Command.run command
