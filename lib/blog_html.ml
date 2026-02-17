type t = {
  index_html_page : string;
  not_found_html_page : string;
  posts_html_page : string;
  posts : (string * string) list;
}

let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html

let of_blog blog =
  let index_html_page =
    Html_blog_render.render_index_page blog |> html_to_string
  and not_found_html_page =
    Html_blog_render.render_not_found blog |> html_to_string
  and posts =
    List.map
      begin fun blog_post ->
        let html =
          Html_blog_render.render_post_page ~blog blog_post |> html_to_string
        in

        (blog_post.uri, html)
      end
      blog.posts
  and posts_html_page =
    Html_blog_render.render_posts_page blog |> html_to_string
  in

  { index_html_page; not_found_html_page; posts_html_page; posts }
