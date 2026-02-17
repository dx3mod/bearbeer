open Containers

module Utils = struct
  let ( // ) = Filename.concat

  let make_directory ?(perm = 0o755) path =
    if not @@ Sys.file_exists path then begin
      Sys.mkdir path perm;
      Dolog.Log.info "Created a %s directory" path
    end

  let write_contents_to_file filename contents =
    Out_channel.with_open_text filename (fun oc -> output_string oc contents);
    Dolog.Log.info "Wrote to a %s file" filename

  let copy_directory ~src ~dst =
    Diskuvbox.copy_dir ~src ~dst () |> Result.get_exn;
    Dolog.Log.info "Copy a %s directory by a %s path" (Fpath.to_string src)
      (Fpath.to_string dst)
end

let generate_from_blog_html ~project_root_dir
    ~(blog_html : Bearbeer.Blog_html.t) ~output_dir =
  let open Utils in
  Dolog.Log.info "Start static generation of your blog into %s folder"
    output_dir;

  make_directory output_dir;
  make_directory (output_dir // "posts");

  write_contents_to_file (output_dir // "index.html") blog_html.index_html_page;
  write_contents_to_file
    (output_dir // "style.css")
    Bearbeer.Resources.bearneo_css;

  write_contents_to_file (output_dir // "posts.html") blog_html.posts_html_page;
  write_contents_to_file (output_dir // "404.html")
    blog_html.not_found_html_page;

  copy_directory
    ~src:(Fpath.v @@ (project_root_dir // "public"))
    ~dst:(Fpath.v @@ (output_dir // "public"));

  List.iter
    (fun (filename, html_contents) ->
      write_contents_to_file ((output_dir // filename) ^ ".html") html_contents)
    blog_html.posts;

  Dolog.Log.info "Finish! Your blog are ready..."
