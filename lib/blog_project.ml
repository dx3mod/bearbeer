open Containers

type configuration = {
  name : string;
  language : string; [@default "en"]
  author : string option; [@default None]
  posts_dir : string; [@default "posts"]
  public_dir : string; [@default "public"]
}
[@@deriving make, of_yaml]

type t = {
  root_dir : string;
  config : configuration;
  posts : (string * Contents_loader.Page.t) list;
  index_page : Contents_loader.Page.t;
}

let public_dir blog = Filename.concat blog.root_dir blog.config.public_dir
let find_post blog filename = List.assoc ~eq:String.equal filename blog.posts

exception Load_configuration_error of string

let load_configuration filename =
  In_channel.with_open_text filename @@ fun ic ->
  In_channel.input_all ic |> Yaml.of_string_exn |> configuration_of_yaml
  |> Result.get_lazy (fun (`Msg msg) -> raise @@ Load_configuration_error msg)

let load_from_dir root_dir =
  let config = load_configuration @@ Filename.concat root_dir "bearbeer.yml" in
  let posts =
    Contents_loader.load_posts_from_dir
    @@ Filename.concat root_dir config.posts_dir
  in

  let index_page =
    Contents_loader.load_page @@ Filename.concat root_dir "index.md"
  in

  { root_dir; config; posts; index_page }
