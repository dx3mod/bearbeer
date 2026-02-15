module Live_demonstration = struct
  let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html

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

module Static_site_generation = struct end

let main project_root_dir =
  let blog =
    Bearbeer.Blog_loader.load_blog_project_from_dir Fpath.(v project_root_dir)
  in

  Live_demonstration.serve ~project_root_dir blog

let () = Cli.run main
