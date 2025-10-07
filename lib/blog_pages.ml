module Page = struct
  type t = { attrs : Yaml.value; contents : Omd.doc }

  let of_string str =
    let attrs, contents = Frontmatter.of_string str |> Result.get_ok in

    {
      attrs = Option.fold ~some:Fun.id ~none:(`O []) attrs;
      contents = Omd.of_string contents;
    }
end

module Post_page = struct
  type attrs = { data : string } [@@deriving of_yaml]
  type t = { attrs : attrs; contents : Omd.doc }

  let of_string str =
    let { attrs; contents } : Page.t = Page.of_string str in

    {
      attrs =
        (match attrs_of_yaml attrs with
        | Ok x -> x
        | Error (`Msg msg) -> failwith msg);
      contents;
    }
end
