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

  let render_posts_list (post_pages : Post_page.t list) =
    let open Html in
    let title_of_post_page (post_page : Post_page.t) = post_page.title in

    div
      [
        ul
        @@ List.map
             (fun post_page ->
               li
                 [
                   p [ b [ txt @@ title_of_post_page post_page ] ];
                   p ~a:[ a_style "color: gray;" ] [ txt post_page.description ];
                 ])
             post_pages;
      ]

  let render_index_page ?(links = []) ~posts ?avatar_src md_page =
    let open Html in
    let nav_links =
      List.map
        (fun ({ title; url } : Blog_config.link) ->
          a ~a:[ a_href url ] [ txt title ])
        links
    in

    let img_avatar src =
      img ~src ~alt:"user's photo"
        ~a:[ a_style "border-radius: 10px; width: 20%" ]
        ()
    in

    render_page
    @@ div
         [
           header
             [
               div [ Option.map_or ~default:(div []) img_avatar avatar_src ];
               h1 ~a:[ a_style "margin-bottom: 0;" ] [ txt Opts.title ];
             ];
           nav nav_links;
           Unsafe.data @@ Omd.to_html md_page;
           br ();
           h3 [ txt "Posts" ];
           render_posts_list posts;
         ]
end
