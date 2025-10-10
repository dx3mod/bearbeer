module type Options = sig
  val title : string
  val language : string
  val basic_url : string
  val footer : [> `Div | `Footer ] Tyxml_html.elt
  val head : Html_types.head_content_fun Tyxml_html.elt list
  val body : Html_types.body_content_fun Tyxml_html.elt list
end

module Make (Opts : Options) = struct
  open Tyxml

  let with_basic_url = Printf.sprintf "%s/%s" Opts.basic_url

  let render_page ?title:(title' = Opts.title) contents =
    let open Html in
    let head_section =
      head (title @@ txt title')
      @@ [
           link ~rel:[ `Stylesheet ]
             ~href:(with_basic_url "static/style.css")
             ();
         ]
      @ Opts.head
    and body_section = body @@ [ contents; Opts.footer ] @ Opts.body in

    html ~a:[ a_lang Opts.language ] head_section body_section

  let render_index_page ?(links = []) ?(avatar_src = "z") md_page =
    let open Html in
    let nav_links =
      List.map
        (fun ({ title; url } : Blog_config.link) ->
          a ~a:[ a_href url ] [ txt title ])
        links
    in

    render_page
    @@ div
         [
           header
             [
               div
                 [
                   img ~src:avatar_src ~alt:"user's photo"
                     ~a:[ a_style "border-radius: 10px; width: 20%" ]
                     ();
                   h1 [ txt Opts.title ];
                 ];
               nav nav_links;
               Unsafe.data @@ Omd.to_html md_page;
             ];
         ]
end
