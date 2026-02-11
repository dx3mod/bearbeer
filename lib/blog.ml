open Containers

type t = {
  root_dir : Fpath.t;  (** The root project directory path. *)
  config : Blog_config.t;
  index_page : Blog_page.t;
  posts : Blog_page.t list;
}

let group_posts_by_year blog =
  let eq page_a page_b =
    page_a.Blog_page.metadata.publish_date.year
    = page_b.Blog_page.metadata.publish_date.year
  and hash page = page.Blog_page.metadata.publish_date.year in

  List.group_by ~eq ~hash blog.posts
  |> List.map @@ fun posts_group ->
     let common_year =
       (List.hd posts_group).Blog_page.metadata.publish_date.year
       |> string_of_int
     and posts = List.sort Blog_page.compare_by_publish_date posts_group in
     (common_year, posts)
