open! Core
include Float

let caqti_type = Caqti_type.float
let odds t = if t = 1. then Float.infinity else t /. (1. -. t)
let logit t = if t = 1. then Float.infinity else Float.log (odds t)
let of_odds odds = if odds = Float.infinity then 1. else odds /. (1. +. odds)
let of_logit logit = of_odds (Float.exp logit)

let scale_by_confidence t ~confidence =
  match t with
  | 0. | 0.5 | 1. -> t
  | t ->
    let logit = logit t in
    let scaled_logit = logit *. confidence in
    let scaled_probability = of_logit scaled_logit in
    scaled_probability
;;
