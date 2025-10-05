let of_string input =
  let front_matter_raw_parser =
    let open Angstrom in
    let line = many1 (char '-') *> char '\n' in
    let* _ = line in
    let* value = many_till any_char line in
    let* end_offset = pos in

    return (value |> List.to_seq |> String.of_seq, end_offset)
  in

  let result =
    Angstrom.(parse_string ~consume:Consume.Prefix front_matter_raw_parser)
      input
  in

  match result with
  | Ok (attrs, end_offset) ->
      Yaml.of_string attrs
      |> Result.map (fun attrs ->
             ( Some attrs,
               String.sub input end_offset (String.length input - end_offset) ))
      |> Result.map_error (function `Msg msg -> msg)
  | Error _ -> Ok (None, input)

let of_string_conv ~p input =
  match of_string input with
  | Error e -> Error e
  | Ok (attrs, text) -> (
      match attrs with
      | None -> Ok (None, text)
      | Some attrs -> (
          match p attrs with
          | Ok attrs -> Ok (Some attrs, text)
          | Error (`Msg msg) -> Error msg))
