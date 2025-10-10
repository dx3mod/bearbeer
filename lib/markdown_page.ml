type t = { attrs : Yaml.value; contents : Omd.doc }

let of_string str =
  let attrs, contents = Frontmatter.of_string str |> Result.get_ok in

  {
    attrs = Option.fold ~some:Fun.id ~none:(`O []) attrs;
    contents = Omd.of_string contents;
  }

let of_channel ic = In_channel.input_all ic |> of_string
