open Containers

exception Load_page_error of string

module Page = struct
  let datetime_of_yaml = function
    | `String s ->
        Date_time.of_string s
        |> Result.add_ctx "Content_loader"
        |> Result.map_err (fun msg -> `Msg msg)
    | _ -> Error (`Msg "invalid date time YAML value")

  type datetime = Date_time.t

  type metadata = {
    title : string option; [@default None]
    synopsys : string; [@default ""]
    publish_date : datetime; [@default Date_time.today ()] [@key "date"]
  }
  [@@deriving of_yaml]

  type t = { metadata : metadata; contents : Omd.doc }

  let compare_publish_date page_a page_b =
    Date_time.compare page_a.metadata.publish_date page_b.metadata.publish_date

  let infer_title doc =
    match doc with
    | Omd.Heading (_, 1, Omd.Text (_, title)) :: _ -> Some title
    | _ -> None

  (** @raise Load_page_error *)
  let metadata_of_yaml_exn value =
    metadata_of_yaml value
    |> Result.get_lazy (fun (`Msg msg) -> raise (Load_page_error msg))

  (** @raise Load_page_error *)
  let of_string s =
    let Frontmatter_extractor_yaml.{ attrs; body } =
      Frontmatter_extractor_yaml.of_string s
      |> Result.get_lazy (fun (`Msg msg) -> raise (Load_page_error msg))
    in

    let markdown_contents = Omd.of_string body in
    let metadata =
      attrs |> Option.value ~default:(`O []) |> metadata_of_yaml_exn
    in

    (* inferred title page *)
    let title =
      Option.choice [ metadata.title; infer_title markdown_contents ]
    in

    { contents = markdown_contents; metadata = { metadata with title } }

  let of_channel ic = In_channel.input_all ic |> of_string

  let normalize_links ~link_prefix page =
    let rec normalize_block = function
      | Omd.Paragraph (attrs, inline) ->
          Omd.Paragraph (attrs, normalize_inline inline)
      | block -> block
    and normalize_inline = function
      | Omd.Concat (attrs, inlines) ->
          Omd.Concat (attrs, List.map normalize_inline inlines)
      | Omd.Link (attrs, link) ->
          let destination =
            Fpath.(link_prefix // v link.destination |> normalize |> to_string)
          in

          Omd.Link (attrs, { link with destination })
      | inline -> inline
    in

    { page with contents = List.map normalize_block page.contents }
end

let load_dir ~link_prefix dir_path =
  let load_page filename =
    In_channel.with_open_text
      Filename.(concat dir_path filename)
      Page.of_channel
    |> Page.normalize_links ~link_prefix
  in

  Sys.readdir dir_path |> Array.to_iter |> List.of_iter
  |> List.filter_map begin fun filename ->
      if String.ends_with ~suffix:".md" filename then Some (load_page filename)
      else None
    end
  |> List.sort Page.compare_publish_date
