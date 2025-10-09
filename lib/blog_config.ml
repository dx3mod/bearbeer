type link = { title : string; url : string } [@@deriving of_yaml]

type t = {
  title : string;
  language : string; [@default "en"]
  avatar : string option; [@default None]
  base_url : string; [@default ""]
  links : link list; [@default []]
}
[@@deriving of_yaml]

let of_channel ic =
  In_channel.input_all ic |> Yaml.of_string |> Fun.flip Result.bind of_yaml
