open Containers

let main project_root_dir output_dir =
  let blog =
    Bearbeer.Blog_loader.load_blog_project_from_dir
      Fpath.(v @@ Unix.realpath project_root_dir)
  in

  let blog_html = Bearbeer.Blog_html.of_blog blog in

  (* Check if is static site generation_target *)
  if not (String.is_empty output_dir) then
    Static_generator.generate_from_blog_html ~blog_html ~project_root_dir
      ~output_dir
  else
    (* otherwise run Dream app *)
    Web_serve.serve_dream_app ~blog_html ~project_root_dir

let () =
  Dolog.Log.set_log_level DEBUG;
  Dolog.Log.color_on ();
  Dolog.Log.clear_prefix ();

  Cli.run main
