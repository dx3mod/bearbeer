open Containers

type t = {
  title : string;
  language : string; [@default "en"]
  author : string; [@default ""]
  avatar : string option; [@default None]
  posts_dir : string; [@default "posts"]
  links : (string * string) list; [@default []]
  footer : string; [@default ""]
  enable_subtitle : bool; [@default true]
}
[@@deriving of_yaml]

exception Blog_config_load_error of string

let of_string s =
  Yaml.of_string s |> Result.flat_map of_yaml
  |> Result.get_lazy @@ fun (`Msg msg) -> raise @@ Blog_config_load_error msg

let of_channel ic = In_channel.input_all ic |> of_string
