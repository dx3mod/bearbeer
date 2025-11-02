module Config = struct
  type link = { title : string; url : string } [@@deriving of_yaml]

  type t = {
    title : string;
    language : string; [@default "en"]
    avatar : string option; [@default None]
    base_url : string; [@default ""]
    links : link list; [@default []]
    posts_dir : string; [@default "posts"]
  }
  [@@deriving of_yaml]

  let of_channel ic : (t, [> `Msg of string ]) result =
    In_channel.input_all ic |> Yaml.of_string |> Result.flat_map of_yaml
    (* Hack type system for make `Msg extensible without overhead. *)
    |> Obj.magic
end

type t = {
  root_dir : string;
  config : Config.t;
  posts : Post_page.t list;
  index_page : Markdown_page.t;
}
