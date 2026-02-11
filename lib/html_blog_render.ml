open Containers

let render_blog_skeleton ~blog contents' =
  let open Tyxml.Html in
  let head =
    head
      (title @@ txt blog.Blog.config.title)
      [
        Unsafe.data
          {|<meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">|};
        link ~rel:[ `Stylesheet ] ~href:"/style.css" ();
      ]
  and body = body contents' in

  html ~a:[ a_lang blog.config.language ] head body

let render_index_page blog =
  let open Tyxml.Html in
  let img_avatar =
    let block = div ~a:[ a_style "clear: both;" ] [] in

    blog.Blog.config.avatar
    |> Option.map_or ~default:block @@ fun src ->
       div
         [
           img ~a:[ a_style "width: 15%; float: left;" ] ~src ~alt:"avatar" ();
           block;
         ]
  in

  let nav_links =
    blog.config.links
    |> List.map (fun (name, href) -> a ~a:[ a_href href ] [ txt name ])
    |> nav
  in

  render_blog_skeleton ~blog
    [
      header
        [
          br ();
          img_avatar;
          a
            ~a:[ a_class [ "title" ]; a_href "/" ]
            [ h1 [ txt blog.config.title ] ];
          nav_links;
        ];
      br ();
      main
        ~a:[ a_class [ "content" ] ]
        [ Unsafe.data (Omd.to_html blog.index_page.markdown_contents) ];
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
      a ~a:[]
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

  render_blog_skeleton ~blog
    [ main ~a:[ a_class [ "content" ] ] [ h1 [ txt "Posts" ]; ul_blog_posts ] ]
