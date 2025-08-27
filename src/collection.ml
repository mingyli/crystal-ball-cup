open! Core
include Collection_intf

module Make (Arg : Arg) = struct
  include Arg

  let all' =
    all |> List.map ~f:(fun event -> Event.id event, event) |> Event_id.Map.of_alist_exn
  ;;
end
