open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Crystal

let () =
  let scores () =
    (* Create fake responses with sample probabilities for some events *)
    let fake_probabilities =
      Event_id.Map.of_alist_exn
        [ Event_id.of_int 1, Random.float 1.0
        ; Event_id.of_int 2, Random.float 1.0
        ; Event_id.of_int 3, Random.float 1.0
        ; Event_id.of_int 4, Random.float 1.0
        ; Event_id.of_int 5, Random.float 1.0
        ; Event_id.of_int 6, Random.float 1.0
        ; Event_id.of_int 7, Random.float 1.0
        ; Event_id.of_int 8, Random.float 1.0
        ; Event_id.of_int 9, Random.float 1.0
        ; Event_id.of_int 10, Random.float 1.0
        ; Event_id.of_int 11, Random.float 1.0
        ; Event_id.of_int 12, Random.float 1.0
        ; Event_id.of_int 13, Random.float 1.0
        ; Event_id.of_int 14, Random.float 1.0
        ; Event_id.of_int 15, Random.float 1.0
        ; Event_id.of_int 16, Random.float 1.0
        ; Event_id.of_int 17, Random.float 1.0
        ; Event_id.of_int 18, Random.float 1.0
        ; Event_id.of_int 19, Random.float 1.0
        ; Event_id.of_int 20, Random.float 1.0
        ]
    in
    let fake_responses = Responses.create fake_probabilities in
    let scores = Scores.create (module Crystal_collections.M2025) fake_responses in
    scores
  in
  let scores =
    String.Map.of_alist_exn
      [ "ming", scores ()
      ; "obama", scores ()
      ; "trump", scores ()
      ; "biden", scores ()
      ; "clinton", scores ()
      ; "bush", scores ()
      ; "one", scores ()
      ; "two", scores ()
      ; "three", scores ()
      ; "four", scores ()
      ; "five", scores ()
      ; "six", scores ()
      ]
  in
  let computation = App.standings (module Crystal_collections.M2025) scores in
  Bonsai_web.Start.start ~bind_to_element_with_id:"testbonsai" computation
;;

(* ignore computation *)

module Attribute = struct
  module T = struct
    type t =
      | Name
      | Department
      | Office
    [@@deriving sexp, compare, enumerate]
  end

  include T
  include Sexpable.To_stringable (T)
  include Comparable.Make (T)

  let name_singular = "attribute"
  let name_plural = "attributes"
end

module Widget = Bonsai_web_ui_multi_select.Multi_factor.Make (String) (Attribute)

let subwidgets =
  Attribute.all
  |> List.map ~f:(fun attr ->
    let all_items =
      String.Set.of_list
        (match attr with
         | Name -> [ "Henry VIII"; "Bill Gates"; "Alan Turing"; "Ada Lovelace" ]
         | Department -> [ "Tech"; "The Tudor Court" ]
         | Office -> [ "LDN"; "NYC"; "HKG" ])
    in
    attr, { Widget.default_selection_status = Selected; all_items })
  |> Attribute.Map.of_alist_exn
  |> Value.return
;;

let id_prefix = Value.return "multi-select-widget-example"

let bonsai_computation =
  let%sub widget_result =
    Widget.bonsai
      ~allow_updates_when_focused:`Never
      ~all_keys:(Attribute.Set.of_list Attribute.all)
      ~id_prefix
      subwidgets
  in
  let%arr widget_result = widget_result in
  let open Virtual_dom.Vdom in
  Node.div
    [ Node.h2 [ Node.text "Selection demo" ]
    ; Widget.Result.view_with_keydown_handler widget_result
    ; Node.text
        (sprintf
           "You have selected %d items"
           (Map.data widget_result.selection |> String.Set.union_list |> Set.length))
    ]
;;

let () = Bonsai_web.Start.start ~bind_to_element_with_id:"app" bonsai_computation
