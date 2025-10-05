let html_to_string html = Format.asprintf "%a" (Tyxml.Html.pp ()) html

module Cli_args = struct
  let root_dir = ref "."

  let speclist =
    [ ("--root-dir", Arg.Set_string root_dir, "Path to root of project") ]
end

let () =
  Arg.parse Cli_args.speclist ignore "";

  let config =
    In_channel.with_open_text
      Filename.(concat !Cli_args.root_dir "bearbeer.yml")
      Bearbeer.Blog_config.of_channel
    |> Result.fold ~ok:Fun.id ~error:(fun (`Msg m) -> failwith m)
  in

  let module Pages = Bearbeer.Pages.Make (struct
    let title = config.title
    and language = config.language
    and footer = Tyxml.Html.div []
    and basic_url = config.base_url
  end) in
  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (fun _ ->
             Dream.html @@ html_to_string
             @@ Pages.index ~links:config.links
             @@ In_channel.with_open_text
                  Cli_args.(!root_dir ^ "/index.md")
                  In_channel.input_all);
         ( Dream.get "/static/style.css" @@ fun _ ->
           Lwt.return
           @@ Dream.response ~status:`OK
                ~headers:[ ("Content-Type", "text/css") ]
                Style_css.contents );
       ]
