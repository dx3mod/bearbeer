open Containers

let load_blog_post_page ~project_dir ?posts_dir filename =
  let project_dir' = Fpath.to_string project_dir in

  let filename' =
    Option.map_or ~default:filename
      Filename.(
        fun posts_dir ->
          concat project_dir' posts_dir |> Fun.flip concat filename)
      posts_dir
  in

  let posts_dir = Option.get_or ~default:"./" posts_dir in

  In_channel.with_open_text filename' Blog_page.of_channel
  |> Blog_page.normalize_links_paths ~project_dir ~posts_dir
  |> Blog_page.with_uri Filename.(concat posts_dir filename)

let load_blog_post_pages ~project_dir posts_dir =
  let project_dir' = Fpath.to_string project_dir in

  Sys.readdir Filename.(concat project_dir' posts_dir)
  |> Array.to_list
  |> List.map @@ load_blog_post_page ~project_dir ~posts_dir

let load_blog_project_from_dir root_project_dir =
  let root_project_dir' = Fpath.to_string root_project_dir in

  let config =
    In_channel.with_open_text
      Filename.(concat root_project_dir' "bearbeer.yml")
      Blog_config.of_channel
  in

  let index_page =
    load_blog_post_page ~project_dir:root_project_dir
    @@ Filename.concat root_project_dir' "index.md"
  in

  let posts =
    load_blog_post_pages ~project_dir:root_project_dir config.posts_dir
  in

  Blog.{ root_dir = root_project_dir; config; index_page; posts }
