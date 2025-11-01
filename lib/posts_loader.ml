module Load_page_error = struct
  type t = { filename : string; reason : string }

  let pp fmt { filename; reason } =
    Format.fprintf fmt "File %s: %s" filename reason
end

let load_post_pages ~root_dir =
  let aux filename =
    let filename = Filename.concat root_dir filename in

    In_channel.with_open_text filename Markdown_page.of_channel
    |> Post_page.of_markdown_page
    |> Result.map_err (fun reason -> Load_page_error.{ filename; reason })
  in

  Sys.readdir root_dir |> Array.to_list |> Result.map_l aux
