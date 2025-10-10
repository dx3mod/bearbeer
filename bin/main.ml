(* fucked singleton  *)
module Cli_args = struct
  let root_dir = ref "."

  let speclist =
    [ ("--root-dir", Arg.Set_string root_dir, "Path to root of project") ]

  let parse () = Arg.parse speclist ignore ""
end

let html_to_string = Format.asprintf "%a" @@ Tyxml.Html.pp ()

let () =
  Cli_args.parse ();

  Sys.chdir !Cli_args.root_dir;

  let blog_config =
    In_channel.with_open_text "bearbeer.yml" Bearbeer.Blog_config.of_channel
  in

  let footer =
    try
      let open Tyxml.Html in
      footer
        [ (Unsafe.data @@ In_channel.(with_open_text "footer.html" input_all)) ]
    with Sys_error _ -> Tyxml.Html.div []
  in

  let module Html_page_render = Bearbeer.Html_page_render.Make (struct
    let title = blog_config.title
    and language = blog_config.language
    and footer = footer

    and head =
      [
        Tyxml.Html.Unsafe.data
          {|<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/night-owl.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js"></script>

|};
      ]

    and body =
      [
        Tyxml.Html.Unsafe.data
          {|
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/ocaml.min.js"></script>
<script>hljs.highlightAll();</script>
|};
      ]

    and basic_url = blog_config.base_url
  end) in
  (* RENDERED PAGES *)
  let rendered_index_page =
    html_to_string
    @@ Html_page_render.render_index_page ~links:blog_config.links
         ?avatar_src:blog_config.avatar
    @@ In_channel.(with_open_text "index.md" Bearbeer.Markdown_page.of_channel)
         .contents
  in

  (* DREAM APP *)
  let return_static_css_file _ =
    Lwt.return
    @@ Dream.response ~status:`OK
         ~headers:[ ("Content-Type", "text/css") ]
         Theme.style_css
  in

  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (fun _ -> Dream.html rendered_index_page);
         Dream.get "/static/style.css" return_static_css_file;
       ]
