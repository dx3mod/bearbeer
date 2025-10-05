module Post = struct
  type t = { title : string; authors : string list [@default []] }
  [@@deriving of_yaml]

  let pp ppf { title; authors } =
    Fmt.pf ppf "title: %s, authors: [%a]" title (Fmt.list Fmt.string) authors

  let testable = Alcotest.testable pp ( = )
end

(* let post_testable = Alcotest.testable  (Fmt.record [Fmt.string; Fmt.list Fmt.string]) (fun expected) *)

let test_parse_post input () =
  let result_post = Frontmatter.of_string_conv ~p:Post.of_yaml input in

  Alcotest.(check @@ result (pair (option Post.testable) string) string)
    "equal"
    (Ok
       ( Some { title = "Привет, как дела?"; authors = [ "Михаил"; "Andy" ] },
         "\nsome text..." ))
    result_post

let input =
  {|
----------
title: Привет, как дела?
authors: 
  - Михаил
  - Andy
----------

some text...

|}
  |> String.trim

let () =
  let open Alcotest in
  run "Frontmatter"
    [ ("parse-post", [ test_case "Equal" `Quick (test_parse_post input) ]) ]
