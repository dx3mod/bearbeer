let eval code =
  let as_buf = Lexing.from_string code in
  let parsed = !Toploop.parse_toplevel_phrase as_buf in
  ignore (Toploop.execute_phrase true Format.std_formatter parsed)

let () =
  eval {|#require "bearbeer.datetime";;|};
  eval "#install_printer Date_time.pp;;"
