module Blog_config = Blog_project.Config

let link_css href = Tyxml.Html.(link ~rel:[ `Stylesheet ] ~href ())

module Html_page = struct
  type t = {
    title : string;
    language : string;
    basic_url : string;
    footer : Html_types.footer_content Tyxml_html.elt list;
    in_head : Html_types.head_content_fun Tyxml_html.elt list;
    after_body : Html_types.body_content Tyxml_html.elt list;
  }

  let render settings contents =
    let open Tyxml.Html in
    let head_section =
      head (title @@ txt settings.title)
      @@ [
           link_css @@ settings.basic_url ^ "/static/style.css";
           Unsafe.data
             {| <meta name="viewport" content="width=device-width, initial-scale=1.0"> |};
         ]
      @ settings.in_head
    and body_section =
      body @@ [ contents ] @ settings.after_body @ [ footer settings.footer ]
    in

    html ~a:[ a_lang settings.language ] head_section body_section
end

module Index_page_contents = struct
  type t = {
    title : string;
    links : Blog_config.link list;
    avatar_src : Tyxml.Html.uri option;
    posts : Post_page.t list;
  }

  let rec render settings md_doc =
    let open Tyxml.Html in
    let nav_links =
      List.map
        (fun ({ title; url } : Blog_project.Config.link) ->
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
            div
              [ Option.map_or ~default:(div []) img_avatar settings.avatar_src ];
            h1 ~a:[ a_style "margin-bottom: 0;" ] [ txt settings.title ];
          ];
        nav nav_links;
        Unsafe.data @@ Omd.to_html md_doc;
        br ();
        (* hr (); *)
        h3 [ txt "Posts" ];
        render_posts_list settings.posts;
      ]

  and render_date_post post_page =
    let open Tyxml.Html in
    let[@inline] date_of_post_page (post_page : Post_page.t) =
      Format.to_string Date_time.pp post_page.publish_date
    in

    small [ txt (date_of_post_page post_page) ]

  and render_posts_list (post_pages : Post_page.t list) =
    let open Tyxml.Html in
    let[@inline] title_of_post_page (post_page : Post_page.t) =
      post_page.title
    in

    let post_pages =
      List.sort
        (fun (a : Post_page.t) b ->
          Date_time.compare a.publish_date b.publish_date)
        post_pages
    in

    let link_post post_page =
      a
        ~a:[ a_href @@ Printf.sprintf "/posts/%s" post_page.Post_page.filename ]
        [ txt @@ title_of_post_page post_page ]
    in

    let p_post_header post_page =
      p
        ~a:[ a_style "margin-bottom:0;" ]
        [ b [ link_post post_page; render_date_post post_page ] ]
    in

    let p_post_description (post_page : Post_page.t) =
      p
        ~a:[ a_style "color: gray; margin-top:0;" ]
        [ txt post_page.description ]
    in

    let ul_posts_list_of_list list = ul ~a:[ a_class [ "posts-list" ] ] list in

    let li_of_post_page post_page =
      li [ p_post_header post_page; p_post_description post_page ]
    in

    div [ ul_posts_list_of_list @@ List.map li_of_post_page post_pages ]
end

module Post_page_contents = struct
  let render (post_page : Post_page.t) =
    let open Tyxml.Html in
    main
      [
        a ~a:[ a_href "/" ] [ txt "⾕" ];
        p [ Index_page_contents.render_date_post post_page ];
        div [ Unsafe.data @@ Omd.to_html post_page.markdown.contents ];
      ]
end
