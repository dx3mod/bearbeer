open Containers

type metadata = {
  title : string option; [@default None]
  synopsys : string; [@default ""]
  publish_date : Date_time.t; [@default Date_time.today ()] [@key "date"]
}
[@@deriving of_yaml]

type t = { metadata : metadata; markdown_contents : Omd.doc }

let compare_by_publish_date page_a page_b =
  Date_time.compare page_a.metadata.publish_date page_b.metadata.publish_date

let infer_title doc =
  match doc with
  | Omd.Heading (_, 1, Omd.Text (_, title)) :: _ -> Some title
  | _ -> None

exception Extract_frontmatter_error of string
exception Parse_metadata_yaml_error of string

let extract_front_matter_exn s =
  Frontmatter_extractor_yaml.of_string s
  |> Result.get_lazy @@ fun (`Msg msg) -> raise @@ Extract_frontmatter_error msg

and metadata_of_yaml_exn value =
  metadata_of_yaml value
  |> Result.get_lazy @@ fun (`Msg msg) -> raise @@ Parse_metadata_yaml_error msg

let of_string s =
  let Frontmatter_extractor_yaml.{ attrs; body } = extract_front_matter_exn s in

  let markdown_contents = Omd.of_string body in
  let metadata =
    attrs |> Option.value ~default:(`O []) |> metadata_of_yaml_exn
  in
  let inferred_title_page =
    Option.choice [ metadata.title; infer_title markdown_contents ]
  in

  {
    markdown_contents;
    metadata = { metadata with title = inferred_title_page };
  }

let of_channel ic = In_channel.input_all ic |> of_string

exception Invalid_markdown_link_path of string

let normalize_links_paths ~project_dir page =
  let rec normalize_block = function
    | Omd.Paragraph (attrs, inline) ->
        Omd.Paragraph (attrs, normalize_inline inline)
    | block -> block
  and normalize_inline = function
    | Omd.Concat (attrs, inlines) ->
        Omd.Concat (attrs, List.map normalize_inline inlines)
    | Omd.Link (attrs, link) ->
        let normalized_path =
          Fpath.(project_dir / "posts" // v link.destination) |> Fpath.normalize
        in

        let destination =
          Fpath.rem_prefix project_dir normalized_path
          |> Option.get_lazy (fun () ->
              raise @@ Invalid_markdown_link_path link.destination)
          |> Fpath.to_string |> ( ^ ) "/"
        in

        Omd.Link (attrs, { link with destination })
    | inline -> inline
  in

  {
    page with
    markdown_contents = List.map normalize_block page.markdown_contents;
  }
