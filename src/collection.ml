open! Core
include Collection_intf

type t = (module S)

let name (module Collection : S) = Collection.name
let all (module Collection : S) = Collection.all
let all' (module Collection : S) = Collection.all'

module Make (Arg : Arg) = struct
  include Arg

  let all' =
    all |> List.map ~f:(fun event -> Event.id event, event) |> Event_id.Map.of_alist_exn
  ;;
end
