open! Core
include Float

let caqti_type = Caqti_type.float
let odds t = t /. (1. -. t)
let logit t = Float.log (odds t)
let of_odds odds = odds /. (1. +. odds)
let of_logit logit = of_odds (Float.exp logit)

let scale_by_confidence t ~confidence =
  if t = 0.
  then 0.
  else if t = 1.
  then 1.
  else if Float.is_inf confidence
  then 0.5
  else (
    let logit = logit t in
    let scaled_logit = logit *. confidence in
    let scaled_probability = of_logit scaled_logit in
    scaled_probability)
;;
