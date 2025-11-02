(** Simple date format implementation. *)

type t = { year : int; month : int; day : int }
(** Representation of date in simple format. *)

val of_string : string -> (t, [> `Invalid_date_value of string ]) result
(** Scan the string for date values else return an error. *)

val of_localtime : Unix.tm -> t
(** [of_localtime localtime] convert Unix localtime record to {!t}. *)

val today : unit -> t
(** [today ()] returns current local date time. *)

val compare : t -> t -> int
(** Compare two dates. *)

val pp : Format.formatter -> t -> unit
(** [pp fmt date] pretty print to format the [date]. *)
