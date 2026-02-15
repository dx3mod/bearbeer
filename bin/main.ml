open Containers

let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html

module Serve = struct
  let serve ~project_root_dir blog =
    Dream.run @@ Dream.logger
    @@ Dream.router
         [
           Dream.get "/public/**"
           @@ Dream.static Filename.(concat project_root_dir "public");
           Dream.get "/favicon.ico" (fun _ ->
               let favicon_filename =
                 Filename.concat project_root_dir "favicon.ico"
               in

               if Sys.file_exists favicon_filename then
                 In_channel.with_open_bin
                   Filename.(concat project_root_dir "favicon.ico")
                   In_channel.input_all
                 |> Dream.respond
               else Dream.empty `Not_Found);
           Dream.get "/style.css" (fun _ ->
               Dream.respond @@ Bearbeer.Resources.bearneo_css);
           Dream.get "/" begin fun _ ->
               Bearbeer.Html_blog_render.render_index_page blog
               |> html_to_string |> Dream.html
             end;
           Dream.get "/posts" begin fun _ ->
               Bearbeer.Html_blog_render.render_posts_page blog
               |> html_to_string |> Dream.html
             end;
           Dream.get "/posts/:name" begin fun request ->
               let post_name = Dream.param request "name" in

               let blog_post =
                 Bearbeer.Blog.find_post_by_name blog ("posts/" ^ post_name)
               in

               Bearbeer.Html_blog_render.render_post_page ~blog blog_post
               |> html_to_string |> Dream.html
             end;
         ]
end

module Static_site_generation = struct
  let ( // ) = Filename.concat

  let make_directory ?(perm = 0o755) path =
    if not @@ Sys.file_exists path then Sys.mkdir path perm

  let write_contents_to_file filename contents =
    Out_channel.with_open_text filename @@ fun oc -> output_string oc contents

  let generate_to_dir ~project_root_dir blog output_dir =
    make_directory output_dir;
    make_directory (output_dir // "posts");

    let index_html_page =
      Bearbeer.Html_blog_render.render_index_page blog |> html_to_string
    in

    write_contents_to_file (output_dir // "index.html") index_html_page;

    write_contents_to_file
      (output_dir // "style.css")
      Bearbeer.Resources.bearneo_css;

    write_contents_to_file
      (output_dir // "posts.html")
      (Bearbeer.Html_blog_render.render_posts_page blog |> html_to_string);

    Diskuvbox.copy_dir
      ~src:(Fpath.v @@ (project_root_dir // "public"))
      ~dst:(Fpath.v @@ (output_dir // "public"))
      ()
    |> Result.get_exn;

    List.iter
      (fun blog_post ->
        Bearbeer.Html_blog_render.render_post_page ~blog blog_post
        |> html_to_string
        |> write_contents_to_file
             ((output_dir // blog_post.Bearbeer.Blog_page.uri) ^ ".html"))
      blog.posts
end

let main project_root_dir output_dir =
  let blog =
    Bearbeer.Blog_loader.load_blog_project_from_dir
      Fpath.(v @@ Unix.realpath project_root_dir)
  in

  if String.is_empty output_dir then Serve.serve ~project_root_dir blog
  else Static_site_generation.generate_to_dir ~project_root_dir blog output_dir

let () = Cli.run main
