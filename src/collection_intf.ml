open! Core

module type S = sig
  val name : string
  val all : Event.t list
end

module type Collection = sig
  module type S = S
end
