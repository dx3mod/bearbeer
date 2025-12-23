(** Frontmatter extractor from pages. *)

type 'attrs t = 'attrs option * string

val of_string : string -> string t
(** [of_string string] extract frontmatter from a [string] as is. *)

val of_string_yaml :
  string -> (Yaml.value t, [> `Yaml_parse_error of string ]) result
(** [of_string_yaml string] extract frontmatter from a [string] and parse it as
    YAML. *)

exception Yaml_parse_error of string

val of_string_yaml_exn : string -> Yaml.value t
(** [of_string_yaml string] extract frontmatter from a [string] and parse it as
    YAML.

    @raise Yaml_parse_error *)

val of_string_yaml_conv :
  (Yaml.value -> ('a, ([> `Yaml_parse_error of string ] as 'error)) result) ->
  string ->
  ('a t, 'error) result
(** [of_string_yaml_conv of_yaml string] extract frontmatter from a [string],
    parse it as YAML and pass it to the [of_yaml] function, and return the
    result. *)
