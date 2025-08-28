open! Core

module type Arg = sig
  val name : string
  val all : Event.t list
end

module type S = sig
  include Arg

  val all' : Event.t Event_id.Map.t
end

module type Collection = sig
  module type S = S

  type t = (module S)

  val name : t -> string
  val all : t -> Event.t list
  val all' : t -> Event.t Event_id.Map.t

  module Make (_ : Arg) : S
end
