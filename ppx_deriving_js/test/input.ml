type t =
  { s : string
  ; i : int
  }
[@@deriving js]

type record_with_array =
  { name : string
  ; values : int array
  }
[@@deriving js]

type nested_record =
  { label : string
  ; data : record_with_array
  }
[@@deriving js]

type variant =
  | Simple
  | WithPayload of string
  | WithRecord of t
[@@deriving js]

type keyed_record =
  { ocaml_name : string [@js_key "jsName"]
  ; other_field : int
  }
[@@deriving js]

type int_alias = int [@@deriving js]
type string_array_alias = string array [@@deriving js]
