open Cmdliner

let project_root_dir =
  let doc = "Project root dir" in
  Arg.(required & pos 0 (some path) None & info [] ~docv:"DIR_PATH" ~doc)

let output_dir =
  let doc = "" in
  Arg.(value & opt string "" & info [ "o"; "output-dir" ] ~docv:"DIR_PATH" ~doc)

let cmd f =
  Cmd.v (Cmd.info "bearbeer") Term.(const f $ project_root_dir $ output_dir)

let run f = exit @@ Cmd.eval @@ cmd f
