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
    | Omd.Heading (_, _, Omd.Text (_, title)) :: _ -> Some title
    | _ -> None
  in

  let { title; description; publish_date } =
    attrs_intf_of_yaml markdown_page.Markdown_page.attrs
    |> Result.fold ~ok:Fun.id ~error:(fun (`Msg reason) ->
        raise (Frontmatter.Yaml_parse_error reason))
  in
  let title =
    match Option.or_ title ~else_:inferred_title_page with
    | None -> raise (Project_loader.File_load_error {filename; reason = ""})
    | Some title -> title
  and publish_date =
    match publish_date with
    | None -> Date_time.today ()
    | Some publish_date -> Date_time.of_string publish_date
  in

  { title; description; markdown = markdown_page; publish_date; filename }
