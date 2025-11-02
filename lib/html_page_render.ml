module Blog_config = Blog_project.Config

type page_settings = {
  title : string;
  language : string;
  basic_url : string;
  footer : Html_types.footer_content Tyxml_html.elt list;
  in_head : Html_types.head_content_fun Tyxml_html.elt list;
  after_body : Html_types.body_content Tyxml_html.elt list;
}

let link_css href = Tyxml.Html.(link ~rel:[ `Stylesheet ] ~href ())

let render_page ~settings contents =
  let open Tyxml.Html in
  let head_section =
    head (title @@ txt settings.title)
    @@ [ link_css @@ settings.basic_url ^ "static/style.css" ]
    @ settings.in_head
  and body_section =
    body @@ [ contents ] @ settings.after_body @ [ footer settings.footer ]
  in

  html ~a:[ a_lang settings.language ] head_section body_section

type index_page_settings = {
  title : string;
  links : Blog_config.link list;
  avatar_src : Tyxml.Html.uri option;
  posts : Post_page.t list;
}

let render_posts_list (post_pages : Post_page.t list) =
  let open Tyxml.Html in
  let title_of_post_page (post_page : Post_page.t) = post_page.title in

  div
    [
      ul ~a:[ a_class [ "posts-list" ] ]
      @@ List.map
           (fun post_page ->
             li
               [
                 p [ b [ txt @@ title_of_post_page post_page ] ];
                 p ~a:[ a_style "color: gray;" ] [ txt post_page.description ];
               ])
           post_pages;
    ]

let render_index_page_contents ~settings markdown_contents =
  let open Tyxml.Html in
  let nav_links =
    List.map
      (fun ({ title; url } : Blog_config.link) ->
        a ~a:[ a_href url ] [ txt title ])
      settings.links
  in

  let img_avatar src =
    img ~src ~alt:"user's photo"
      ~a:[ a_style "border-radius: 10px; width: 20%" ]
      ()
  in

  div
    [
      header
        [
          div [ Option.map_or ~default:(div []) img_avatar settings.avatar_src ];
          h1 ~a:[ a_style "margin-bottom: 0;" ] [ txt settings.title ];
        ];
      nav nav_links;
      Unsafe.data @@ Omd.to_html markdown_contents;
      br ();
      h3 [ txt "Posts" ];
      render_posts_list settings.posts;
    ]
