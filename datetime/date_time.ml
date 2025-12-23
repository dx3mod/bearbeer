type t = { year : int; month : int; day : int }

let pp fmt { year; month; day } =
  Format.fprintf fmt "%02d.%02d.%d" day month year

exception Parse_error of string

let of_string s =
  try Scanf.sscanf s "%d.%d.%d" @@ fun day month year -> { year; month; day }
  with Scanf.Scan_failure msg -> raise (Parse_error msg)

let compare da db =
  if da.year = db.year && da.month = db.month && da.day = db.day then 0
  else if da.year < db.year && da.month < db.month && da.day < db.day then -1
  else 1

let of_localtime localtime =
  {
    day = localtime.Unix.tm_mday;
    month = localtime.Unix.tm_mon + 1;
    year = localtime.Unix.tm_year;
  }

let today () = Unix.time () |> Unix.localtime |> of_localtime
