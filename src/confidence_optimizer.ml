open! Core

type t =
  { probs : Probability.t array
  ; outcomes : float array
  }

let create probs outcomes = { probs; outcomes }

let loss t ~confidence =
  let open Float in
  Array.zip_exn t.probs t.outcomes
  |> Array.sum
       (module Float)
       ~f:(fun (p, y) ->
         let scaled_p =
           Probability.scale_by_confidence p ~confidence |> Probability.to_float
         in
         (y * Float.log scaled_p) + ((1. - y) * Float.log (1. - scaled_p)))
  |> Float.( * ) (-1.)
;;

let loss' t ~confidence =
  let open Float in
  Array.zip_exn t.probs t.outcomes
  |> Array.sum
       (module Float)
       ~f:(fun (p, y) ->
         let scaled_p =
           Probability.scale_by_confidence p ~confidence |> Probability.to_float
         in
         let p = Probability.to_float p in
         (y - scaled_p) * (Float.log p - Float.log (1. - p)))
  |> Float.( * ) (-1.)
;;

let loss'' t ~confidence =
  let open Float in
  Array.zip_exn t.probs t.outcomes
  |> Array.sum
       (module Float)
       ~f:(fun (p, _y) ->
         let scaled_p =
           Probability.scale_by_confidence p ~confidence |> Probability.to_float
         in
         let p = Probability.to_float p in
         scaled_p
         * (1. - scaled_p)
         * (Float.log p - Float.log (1. - p))
         * (Float.log p - Float.log (1. - p)))
;;

let step t ~confidence =
  let open Float in
  let loss' = loss' t ~confidence in
  let loss'' = loss'' t ~confidence in
  let confidence = confidence - (loss' / loss'') in
  confidence
;;
