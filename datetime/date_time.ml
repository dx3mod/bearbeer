open Containers

type t = { year : int; month : int; day : int }

let ppf fmt { year; month; day } =
  Format.fprintf fmt "%02d.%02d.%d" day month year

let pp fmt date = Format.fprintf fmt "Date_time(%a)" ppf date

let of_string s =
  let open Parse in
  let number =
    take1_if is_num >|= Fun.(int_of_string % Parse.Slice.to_string)
  in

  let make_date_parser del =
    number <* char del ||| number <* char del ||| number
  in

  let dd_mm_yy =
    make_date_parser '.' >|= fun ((day, month), year) -> { day; month; year }
  and yy_mm_dd =
    make_date_parser '-' >|= fun ((year, month), day) -> { day; month; year }
  in

  parse_string (dd_mm_yy <|> yy_mm_dd) s

let compare da db =
  if da.year = db.year && da.month = db.month && da.day = db.day then 0
  else if da.year < db.year && da.month < db.month && da.day < db.day then -1
  else 1

let of_localtime localtime =
  {
    day = localtime.Unix.tm_mday;
    month = localtime.Unix.tm_mon + 1;
    year = localtime.Unix.tm_year + 1900;
  }

let today () = Unix.time () |> Unix.localtime |> of_localtime

let of_yaml = function
  | `String s ->
      of_string s
      |> Result.add_ctx "Content_loader"
      |> Result.map_err (fun msg -> `Msg msg)
  | _ -> Error (`Msg "invalid date time YAML value")
