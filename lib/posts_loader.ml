exception Not_found_posts_dir

let load_post_pages ~root_dir =
  let load_post_file filename =
    let filename = Filename.concat root_dir filename in

    In_channel.with_open_text filename Markdown_page.of_channel
    |> Post_page.of_markdown_page ~filename:(Filename.basename filename)
  in

  try Sys.readdir root_dir |> Array.to_list |> List.map load_post_file
  with Sys_error _ -> raise Not_found_posts_dir
