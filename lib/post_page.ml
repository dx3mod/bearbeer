type t = { title : string; description : string; markdown : Markdown_page.t }

type attrs_intf = {
  title : string option; [@default None]
  description : string; [@default ""]
}
[@@deriving of_yaml]

let of_markdown_page markdown_page =
  let inferred_title_page =
    match markdown_page.Markdown_page.contents with
    | Omd.Heading (_, _, Omd.Text (_, title)) :: _ -> Ok title
    | _ -> Error "the post not have a title"
  in

  match attrs_intf_of_yaml markdown_page.Markdown_page.attrs with
  | Error (`Msg msg) -> failwith msg
  | Ok { title; description } ->
      Result.(
        let+ title = Option.fold Fun.const inferred_title_page title in

        { title; description; markdown = markdown_page })
