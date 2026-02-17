let serve_dream_app ~(blog_html : Bearbeer.Blog_html.t) ~project_root_dir =
  let favicon =
    let favicon_filename = Filename.concat project_root_dir "favicon.ico" in
    if Sys.file_exists favicon_filename then
      In_channel.with_open_bin
        Filename.(concat project_root_dir "favicon.ico")
        In_channel.input_all
      |> Option.some
    else None
  in

  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/public/**"
         @@ Dream.static Filename.(concat project_root_dir "public");
         Dream.get "/favicon.ico" (fun _ ->
             match favicon with
             | Some favicon -> Dream.respond favicon
             | None -> Dream.empty `Not_Found);
         Dream.get "/style.css" (fun _ ->
             Dream.respond @@ Bearbeer.Resources.bearneo_css);
         Dream.get "/" begin fun _ ->
             Dream.html blog_html.index_html_page
           end;
         Dream.get "/posts" begin fun _ ->
             Dream.html blog_html.posts_html_page
           end;
         Dream.get "/posts/:name" begin fun request ->
             let post_name = Dream.param request "name" in

             try List.assoc ("posts/" ^ post_name) blog_html.posts |> Dream.html
             with Not_found ->
               Dream.html ~status:`Not_Found blog_html.not_found_html_page
           end;
         Dream.get "/**" begin fun _ ->
             Dream.html ~status:`Not_Found blog_html.not_found_html_page
           end;
       ]
