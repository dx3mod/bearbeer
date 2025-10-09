(* fucked singleton  *)
module Cli_args = struct
  let root_dir = ref "."

  let speclist =
    [ ("--root-dir", Arg.Set_string root_dir, "Path to root of project") ]

  let parse () = Arg.parse speclist ignore ""
end

module Make_loader (Opts : sig
  val root_dir : string
  (** Path to project directory. *)
end) =
struct
  open Opts

  let load_blog_page ~of_string filename =
    In_channel.with_open_text (Filename.concat root_dir filename)
    @@ Fun.compose of_string In_channel.input_all

  let load_index_page =
    load_blog_page ~of_string:Bearbeer.Blog_pages.Page.of_string

  and _load_post_page =
    load_blog_page ~of_string:Bearbeer.Blog_pages.Post_page.of_string

  let load_project_config filename =
    In_channel.with_open_text
      (Filename.concat root_dir filename)
      Bearbeer.Blog_config.of_channel
    |> Result.fold ~ok:Fun.id ~error:(fun (`Msg m) -> failwith m)

  let load_html filename =
    In_channel.with_open_text
      (Filename.concat root_dir filename)
      In_channel.input_all
end

let html_to_string = Format.asprintf "%a" @@ Tyxml.Html.pp ()

let () =
  Cli_args.parse ();

  let module Loader = Make_loader (struct
    let root_dir = !Cli_args.root_dir
  end) in
  let blog_config = Loader.load_project_config "bearbeer.yml" in

  let footer =
    try
      let open Tyxml.Html in
      footer [ Unsafe.data @@ Loader.load_html "footer.html" ]
    with Sys_error _ -> Tyxml.Html.div []
  in

  let module Html_pages_builder = Bearbeer.Html_pages_builder.Make (struct
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
  let index_page =
    (Loader.load_index_page "index.md").contents
    |> Html_pages_builder.make_index_page ~links:blog_config.links
         ?avatar_src:blog_config.avatar
    |> html_to_string
  in

  let return_static_css_file _ =
    Lwt.return
    @@ Dream.response ~status:`OK
         ~headers:[ ("Content-Type", "text/css") ]
         Theme.style_css
  in

  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (fun _ -> Dream.html index_page);
         Dream.get "/static/style.css" return_static_css_file;
       ]
