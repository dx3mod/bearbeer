type t = {
  title : string;
  description : string;
  date : Date_time.t;
  markdown : Markdown_page.t;
}

type attrs_intf = {
  title : string option; [@default None]
  description : string; [@default ""]
  date : string option; [@default None]
}
[@@deriving of_yaml]

let of_markdown_page markdown_page =
  let inferred_title_page =
    match markdown_page.Markdown_page.contents with
    | Omd.Heading (_, _, Omd.Text (_, title)) :: _ -> Ok title
    | _ -> Error `Post_not_have_title
  in

  let open Result in
  let* { title; description; date } =
    attrs_intf_of_yaml markdown_page.Markdown_page.attrs
    |> Result.map_err (fun (`Msg m) -> `Yaml_parse_error m)
  in
  let+ title = Option.fold Fun.const inferred_title_page title
  and+ date =
    match date with
    | None -> Ok (Date_time.today ())
    | Some date -> Date_time.of_string date
  in

  { title; description; markdown = markdown_page; date }
