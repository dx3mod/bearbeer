open Containers

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

  render_blog_skeleton ~blog
    [
      header
        [
          br ();
          img_avatar;
          a
            ~a:[ a_class [ "title" ]; a_href "/" ]
            [ h1 [ txt blog.config.title ] ];
        ];
      main [ Unsafe.data (Omd.to_html blog.index_page.markdown_contents) ];
    ]
