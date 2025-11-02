let rec main root_dir =
  let open Result in
  guard_error_to_string
  @@
  let+ blog_project = Bearbeer.Project_loader.load ~root_dir in

  let current_theme =
    Bearbeer.Theme.
      {
        plain_css = Resource_github_theme.plain;
        highlight_themes = { dark = Some "github-dark"; light = Some "github" };
      }
  in

  let link_highlight_theme ~scheme name =
    Tyxml.Html.Unsafe.data
    @@ Printf.sprintf
         {|<link rel="stylesheet" media="(prefers-color-scheme: %s)" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/%s.min.css">|}
         scheme name
  in

  let page_settings =
    Bearbeer.Html_page_render.
      {
        title = blog_project.config.title;
        language = blog_project.config.language;
        basic_url = "";
        footer = [];
        in_head =
          Option.map_or ~default:[]
            (fun name -> [ link_highlight_theme ~scheme:"light" name ])
            current_theme.highlight_themes.light
          @ Option.map_or ~default:[]
              (fun name -> [ link_highlight_theme ~scheme:"dark" name ])
              current_theme.highlight_themes.dark
          @ [
              Tyxml.Html.Unsafe.data
                {|<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js"></script>|};
            ];
        after_body =
          [
            Tyxml.Html.Unsafe.data
              {|
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/ocaml.min.js"></script>
<script>hljs.highlightAll();</script>
|};
          ];
      }
  in

  let index_page_settings =
    Bearbeer.Html_page_render.
      {
        title = page_settings.title;
        links = blog_project.config.links;
        avatar_src = blog_project.config.avatar;
        posts = blog_project.posts;
      }
  in

  let index_page =
    let open Bearbeer.Html_page_render in
    render_page ~settings:page_settings
    @@ render_index_page_contents ~settings:index_page_settings
         blog_project.index_page.contents
  in

  let return_static_css_file =
    let style_css = current_theme.plain_css ^ Resource_style_css.plain in

    fun _ ->
      Lwt.return
      @@ Dream.response ~status:`OK
           ~headers:[ ("Content-Type", "text/css") ]
           style_css
  in

  let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html in

  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (fun _ -> Dream.html @@ html_to_string index_page);
         Dream.get "/static/style.css" return_static_css_file;
       ]

and guard_error_to_string r =
  let handle_load_page_error fmt = function
    | `Post_not_have_title -> Format.fprintf fmt "the post not have a title"
    | `Yaml_parse_error msg | `Invalid_date_value msg ->
        Format.pp_print_string fmt msg
  in

  let aux = function
    | `Msg msg -> failwith @@ Printf.sprintf "guard_error_to_string: %s" msg
    | `Load_page_error (filename, err) ->
        Format.sprintf "at %s file.\nLoad page error:\n\t%a" filename
          handle_load_page_error err
    | `File_load_error (filename, msg) ->
        Printf.sprintf "at %s file.\n%s" filename msg
    | _ -> "something went wrong"
  in
  Result.map_err aux r

let () = exit @@ Cmdliner.Cmd.eval_result @@ Cli.cmd main
