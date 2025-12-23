type t = { attrs : Yaml.value; contents : Omd.doc }

let of_string str =
  let attrs, contents = Frontmatter.of_string_yaml_exn str in

  {
    attrs = Option.get_or ~default:(`O []) attrs;
    contents = Omd.of_string contents;
  }

let of_channel ic = In_channel.input_all ic |> of_string
