open Cmdliner

let root_dir_arg =
  Arg.(
    value & opt path "."
    & info [ "d"; "root-dir" ] ~docv:"PATH"
        ~doc:"Path to root of project's directory.")

let cmd handle =
  let doc = "blogging for drunks" in
  let info = Cmd.info "bearbeer" ~doc in
  Cmd.v info Term.(const handle $ root_dir_arg)
