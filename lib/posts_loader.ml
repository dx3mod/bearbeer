let load_post_pages ~root_dir =
  let aux filename =
    let filename = Filename.concat root_dir filename in

    In_channel.with_open_text filename Markdown_page.of_channel
    |> Result.flat_map Post_page.of_markdown_page
    |> Result.map_err (fun e -> `Load_page_error (filename, e))
  in

  Sys.readdir root_dir |> Array.to_list |> Result.map_l aux
