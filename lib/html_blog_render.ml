let render_blog_skeleton ~blog contents =
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
  and body = body contents in

  html ~a:[ a_lang blog.config.language ] head body

let render_index_page blog =
  let open Tyxml.Html in
  render_blog_skeleton ~blog
    [
      header
        [
          a
            ~a:[ a_class [ "title" ]; a_href "/" ]
            [ h1 [ txt blog.config.title ] ];
        ];
      main [ Unsafe.data (Omd.to_html blog.index_page.markdown_contents) ];
    ]
