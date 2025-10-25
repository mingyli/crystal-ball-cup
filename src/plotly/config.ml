open! Core

type t =
  { display_mode_bar : bool [@jsobject.key "displayModeBar"]
  ; displaylogo : bool
  }
[@@deriving jsobject]
