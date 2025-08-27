open! Core

val create_and_populate
  :  (module Collection.S)
  -> output_file:string
  -> responses:Responses.t String.Map.t
  -> scores:Scores.t String.Map.t
  -> unit Or_error.t
