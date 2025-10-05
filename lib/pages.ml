module type PageOptions = sig
  val title : string
  val language : string
  val footer : [> Html_types.flow5 ] Tyxml.Html.elt
  val basic_url : string
end

module Make (O : PageOptions) = struct
  open Tyxml

  let with_basic_url = Printf.sprintf "%s/%s" O.basic_url

  let basic contents =
    let style_css_link =
      Html.(
        link ~rel:[ `Stylesheet ] ~href:(with_basic_url "static/style.css") ())
    in

    Html.(
      html
        ~a:[ a_lang O.language ]
        (head (title (txt O.title)) [ style_css_link ])
        (body [ contents; O.footer ]))

  let index ?(links = []) contents =
    let open Html in
    let nav_links =
      List.map
        (fun ({ title; url } : Blog_config.link) ->
          a ~a:[ a_href url ] [ txt title ])
        links
    in

    let contents_html =
      Frontmatter.of_string contents
      |> Result.get_ok |> snd |> Omd.of_string |> Omd.to_html
    in

    basic
    @@ div
         [
           header
             [ h1 [ txt O.title ]; nav nav_links; Unsafe.data contents_html ];
         ]
end
