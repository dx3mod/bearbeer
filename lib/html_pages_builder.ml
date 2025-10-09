module Make (O : sig
  val title : string
  val language : string
  val basic_url : string
  val footer : [> `Div | `Footer ] Tyxml_html.elt
  val head : Html_types.head_content_fun Tyxml_html.elt list
  val body : Html_types.body_content_fun Tyxml_html.elt list
end) =
struct
  open Tyxml

  let with_basic_url = Printf.sprintf "%s/%s" O.basic_url

  let make_basic_page contents =
    let open Html in
    let head_section =
      head (title @@ txt O.title)
      @@ [
           link ~rel:[ `Stylesheet ]
             ~href:(with_basic_url "static/style.css")
             ();
         ]
      @ O.head
    and body_section = body @@ [ contents; O.footer ] @ O.body in

    html ~a:[ a_lang O.language ] head_section body_section

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
