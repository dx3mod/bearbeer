type t = {
  title : string;
  description : string;
  publish_date : Date_time.t;
  markdown : Markdown_page.t;
  filename : string;
}

type attrs_intf = {
  title : string option; [@default None]
  description : string; [@default ""]
  publish_date : string option; [@default None]
}
[@@deriving of_yaml ~skip_unknown]

let of_markdown_page ~filename markdown_page =
  let inferred_title_page =
    match markdown_page.Markdown_page.contents with
    | Omd.Heading (_, _, Omd.Text (_, title)) :: _ -> Ok title
    | _ -> Error `Post_not_have_title
  in

  let open Result in
  let* { title; description; publish_date } =
    attrs_intf_of_yaml markdown_page.Markdown_page.attrs
    |> Result.map_err (fun (`Msg m) -> `Yaml_parse_error m)
  in
  let+ title = Option.fold Fun.const inferred_title_page title
  and+ publish_date =
    match publish_date with
    | None -> Ok (Date_time.today ())
    | Some publish_date -> Date_time.of_string publish_date
  in

  { title; description; markdown = markdown_page; publish_date; filename }
