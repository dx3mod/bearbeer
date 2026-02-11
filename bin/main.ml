let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html

let main project_root_dir =
  let blog =
    Bearbeer.Blog_loader.load_blog_project_from_dir Fpath.(v project_root_dir)
  in

  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/public/**"
         @@ Dream.static Filename.(concat project_root_dir "public");
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

let () = Cli.run main
