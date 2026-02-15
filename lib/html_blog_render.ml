open Containers

let render_blog_skeleton ?(subtitle = "") ~blog contents' =
  let open Tyxml.Html in
  let subtitle =
    if (not blog.Blog.config.enable_subtitle) || String.is_empty subtitle then
      ""
    else " | " ^ subtitle
  in

  let head =
    head
      (title @@ txt @@ blog.Blog.config.title ^ subtitle)
      [
        Unsafe.data
          {|<meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">|};
        link ~rel:[ `Stylesheet ] ~href:"/style.css" ();
        Unsafe.data
          {|<link rel="icon" type="image/x-icon" href="/favicon.ico">|};
      ]
  and body = body contents' in

  html ~a:[ a_lang blog.config.language ] head body

let render_footer blog =
  let open Tyxml.Html in
  footer [ Unsafe.data blog.Blog.config.footer ]

let render_header_avatar blog =
  let open Tyxml.Html in
  let block = div ~a:[ a_style "clear: both;" ] [] in

  blog.Blog.config.avatar
  |> Option.map_or ~default:block @@ fun src ->
     div
       [
         a
           ~a:[ a_href "/" ]
           [
             img ~a:[ a_style "width: 15%; float: left;" ] ~src ~alt:"avatar" ();
             block;
           ];
       ]

let render_header blog =
  let open Tyxml.Html in
  let nav_links =
    blog.Blog.config.links
    |> List.map (fun (name, href) -> a ~a:[ a_href href ] [ txt name ])
    |> nav
  in

  header
    [
      br ();
      render_header_avatar blog;
      a ~a:[ a_class [ "title" ]; a_href "/" ] [ h1 [ txt blog.config.title ] ];
      nav_links;
    ]

let render_index_page blog =
  let open Tyxml.Html in
  render_blog_skeleton ~blog
    [
      render_header blog;
      br ();
      main
        ~a:[ a_class [ "content" ] ]
        [ Unsafe.data (Omd.to_html blog.index_page.markdown_contents) ];
      render_footer blog;
    ]

let render_post_item page =
  let open Tyxml.Html in
  li
    [
      span
        ~a:[ a_class [ "grouped" ] ]
        [
          time
            [
              txt @@ Date_time.to_string page.Blog_page.metadata.publish_date;
              space ();
              space ();
            ];
        ];
      a
        ~a:[ a_href @@ page.uri ]
        [
          txt
          @@ Option.get_exn_or "unknown title for post"
               page.Blog_page.metadata.title;
        ];
    ]

let render_posts_page blog =
  let open Tyxml.Html in
  let render_li_blog_post_item (common_year, posts) =
    [ li [ h3 [ txt common_year ] ] ] @ List.map render_post_item posts
  in

  let posts_by_years = Blog.group_posts_by_year blog in

  let ul_blog_posts =
    posts_by_years
    |> List.flat_map render_li_blog_post_item
    |> ul ~a:[ a_class [ "blog-posts" ] ]
  in

  render_blog_skeleton ~blog ~subtitle:"Posts"
    [
      render_header blog;
      main
        ~a:[ a_class [ "content" ] ]
        [
          br ();
          p
            [
              txt
              @@ Printf.sprintf "There are %d pieces."
              @@ Blog.count_posts blog;
            ];
          ul_blog_posts;
        ];
      render_footer blog;
    ]

let render_post_page ~blog post_page =
  let open Tyxml.Html in
  let title =
    Option.get_exn_or "unknown post page title"
      post_page.Blog_page.metadata.title
  and publish_date = Date_time.to_string post_page.metadata.publish_date in

  let tags =
    post_page.metadata.tags
    |> List.map (fun tag ->
        li [ a ~a:[ a_style "color:gray;" ] [ txt @@ "#" ^ tag ] ])
    |> ul ~a:[ a_class [ "tags" ] ]
  in

  render_blog_skeleton ~subtitle:title ~blog
    [
      main
        ~a:[ a_class [ "content" ] ]
        [
          a ~a:[ a_href "/" ] [ txt "家" ];
          h1 [ txt title ];
          p [ i [ time ~a:[ a_datetime publish_date ] [ txt publish_date ] ] ];
          div
            ~a:[ a_style "color:gray;" ]
            [ small [ txt post_page.metadata.synopsys ]; tags ];
          hr ();
          (* br (); *)
          Unsafe.data (Omd.to_html post_page.markdown_contents);
        ];
      render_footer blog;
    ]
