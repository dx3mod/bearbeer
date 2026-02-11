type t = {
  root_dir : Fpath.t;  (** The root project directory path. *)
  config : Blog_config.t;
  index_page : Blog_page.t;
  posts : Blog_page.t list;
}
