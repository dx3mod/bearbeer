let load_project_config filename =
  try In_channel.with_open_text filename Blog_project.Config.of_channel
  with Sys_error msg -> Error (`File_load_error (filename, msg))

let load_index_page filename =
  try In_channel.with_open_text filename Markdown_page.of_channel
  with Sys_error msg -> Error (`File_load_error (filename, msg))

let load ~root_dir =
  let open Result in
  Sys.chdir root_dir;

  let* config = load_project_config "bearbeer.yml" in
  let* index_page = load_index_page "index.md" in
  let* posts = Posts_loader.load_post_pages ~root_dir:config.layout.posts_dir in

  return Blog_project.{ root_dir; config; posts; index_page }
