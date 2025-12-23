exception Parse_error of string

module Config = struct
  type link = { title : string; url : string } [@@deriving of_yaml]

  type layout = {
    posts_dir : string; [@default "posts"]
    public_dir : string; [@default "public"]
  }
  [@@deriving of_yaml, make]

  type t = {
    title : string;
    language : string; [@default "en"]
    avatar : string option; [@default None]
    base_url : string; [@default ""]
    links : link list; [@default []]
    layout : layout; [@default make_layout ()]
  }
  [@@deriving of_yaml]

  let of_channel ic =
    In_channel.input_all ic |> Yaml.of_string |> Result.flat_map of_yaml
    |> Result.fold ~ok:Fun.id ~error:(fun (`Msg reason) ->
        raise (Parse_error reason))
end

type t = {
  root_dir : string;
  config : Config.t;
  posts : Post_page.t list;
  index_page : Markdown_page.t;
}
