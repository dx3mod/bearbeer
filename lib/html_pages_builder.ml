module Make (O : sig
  val title : string
  val language : string
  val footer : [> Html_types.flow5 ] Tyxml.Html.elt
  val basic_url : string
end) =
struct
  open Tyxml

  let with_basic_url = Printf.sprintf "%s/%s" O.basic_url

  let make_basic_page contents =
    let style_css_link =
      Html.(
        link ~rel:[ `Stylesheet ] ~href:(with_basic_url "static/style.css") ())
    in

    Html.(
      html
        ~a:[ a_lang O.language ]
        (head
           (title (txt O.title))
           [
             style_css_link;
             Unsafe.data
               {|  <meta name="viewport" content="width=device-width, initial-scale=1.0" />|};
           ])
        (body [ contents; O.footer ]))

  let make_index_page ?(links = []) ?(avatar_src = "z") contents =
    let open Html in
    let nav_links =
      List.map
        (fun ({ title; url } : Blog_config.link) ->
          a ~a:[ a_href url ] [ txt title ])
        links
    in

    make_basic_page
    @@ div
         [
           header
             [
               div
                 [
                   img ~src:avatar_src ~alt:"user's photo"
                     ~a:[ a_style "border-radius: 10px; width: 20%" ]
                     ();
                   h1 [ txt O.title ];
                 ];
               nav nav_links;
               Unsafe.data @@ Omd.to_html contents;
             ];
         ]
end
