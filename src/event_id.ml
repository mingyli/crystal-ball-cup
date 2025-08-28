open! Core
open Import
include Int

let yojson_of_t = yojson_of_int
let caqti_type = Caqti_type.int

module Map = struct
  include Map

  let yojson_of_t yojson_of_a t =
    `Assoc
      (Core.Map.to_alist t
       |> List.map ~f:(fun (event_id, score) -> Int.to_string event_id, yojson_of_a score)
      )
  ;;
end
