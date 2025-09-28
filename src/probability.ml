open! Core
include Float

let caqti_type = Caqti_type.float

let odds t = t /. (1. -. t)
let logit t = Float.log (odds t)

let of_odds odds = odds /. (1. +. odds)
let of_logit logit = of_odds (Float.exp logit)
