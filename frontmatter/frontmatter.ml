type t = string option * string

let of_string input =
  let front_matter_raw_parser =
    let open Angstrom in
    let line = many1 (char '-') *> char '\n' in
    let* _ = line in
    let* value = many_till any_char line in
    let* end_offset = pos in

    return (value |> List.to_seq |> String.of_seq, end_offset)
  in

  Angstrom.(parse_string ~consume:Consume.Prefix front_matter_raw_parser) input
  |> Result.fold ~error:(Fun.const (None, input))
       ~ok:begin fun (frontmatter, end_offset) ->
       ( Some frontmatter,
         String.sub input end_offset (String.length input - end_offset) )
       end

let of_string_yaml input =
  match of_string input with
  | None, contents -> Ok (None, contents)
  | Some frontmatter, contents ->
      Yaml.of_string frontmatter
      |> Result.map_error (fun (`Msg m) -> `Yaml_parse_error m)
      |> Result.map (fun frontmatter -> (Some frontmatter, contents))

let of_string_yaml_conv p input =
  Result.bind (of_string_yaml input) @@ fun (attrs, contents) ->
  match attrs with
  | None -> Ok (None, contents)
  | Some attrs -> p attrs |> Result.map (fun attrs -> (Some attrs, contents))
