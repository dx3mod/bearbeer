let render_html_page ~config contents =
  let open Tyxml.Html in
  let head =
    head
      (title @@ txt config.Blog_project.name)
      [
        Unsafe.data
          {|<meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">|};
        link ~rel:[ `Stylesheet ] ~href:"/style.css" ();
      ]
  and body = body contents in

  html ~a:[ a_lang config.language ] head body

let render_index_page ~config (page : Contents_loader.Page.t) =
  let open Tyxml.Html in
  render_html_page ~config
    [
      header
        [
          a
            ~a:[ a_class [ "title" ]; a_href "/" ]
            [ h1 [ txt config.Blog_project.name ] ];
        ];
      main [ Unsafe.data (Omd.to_html page.contents) ];
    ]
