let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html

let () =
  let root_dir = Sys.argv.(1) in

  let blog_project = Bearbeer.Blog_project.load_from_dir root_dir in

  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/public/**"
         @@ Dream.static (Bearbeer.Blog_project.public_dir blog_project);
         Dream.get "/style.css" (fun _ ->
             Dream.respond @@ Bearbeer.Resources.bearneo_css);
         Dream.get "/" begin fun _ ->
             Bearbeer.Html_render.render_index_page ~config:blog_project.config
               blog_project.Bearbeer.Blog_project.index_page
             |> html_to_string |> Dream.html
           end;
         Dream.get "/:filename" begin fun request ->
             let filename = Dream.param request "filename" in

             Bearbeer.Blog_project.find_post blog_project filename
             |> Bearbeer.Html_render.render_index_page
                  ~config:blog_project.config
             |> html_to_string |> Dream.html
           end;
       ]
