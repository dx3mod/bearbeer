open Cmdliner

let project_root_dir =
  let doc = "Project root dir" in
  Arg.(required & pos 0 (some path) None & info [] ~docv:"DIRECTORY_PATH" ~doc)

let cmd f = Cmd.v (Cmd.info "bearbeer") Term.(const f $ project_root_dir)
let run f = exit @@ Cmd.eval @@ cmd f
