open! Core

type t

val create : Probability.t array -> float array -> t
val step : t -> confidence:float -> float
val loss : t -> confidence:float -> float
