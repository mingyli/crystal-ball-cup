open! Core

(** [create_and_populate ~output_path ~collection] creates a new SQLite
    database at [output_path], defines the schema, and populates it with data
    from the given [collection]. *)
val create_and_populate
  :  output_path:string
  -> (module Collection.S)
  -> (unit, string) result
