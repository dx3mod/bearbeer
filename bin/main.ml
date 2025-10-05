let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html

module Pages = Bearbeer.Pages.Make (struct
  let title = "ladno"
  and language = "ru"
  and footer = Tyxml.Html.div []
  and basic_url = ""
end)

module Cli_args = struct
  let root_dir = ref "."

  let speclist =
    [ ("--root-dir", Arg.Set_string root_dir, "Path to root of project") ]
end

let () =
  Arg.parse Cli_args.speclist ignore "";

  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (fun _ ->
             Dream.html @@ html_to_string
             @@ Pages.index
                  ~links:[ ("vk", "vk.com"); ("github", "github.com") ]
             @@ In_channel.with_open_text
                  Cli_args.(!root_dir ^ "/index.md")
                  In_channel.input_all);
         ( Dream.get "/static/style.css" @@ fun _ ->
           Lwt.return
           @@ Dream.response ~status:`OK
                ~headers:[ ("Content-Type", "text/css") ]
                Style_css.contents );
       ]
