(lang dune 3.20)

(name bearbeer)

(generate_opam_files true)

(source
 (github dx3mod/bearbeer))

(authors "Mikhail Lopatin <dx3mod@bk.ru>")

(maintainers "Mikhail Lopatin <dx3mod@bk.ru>")

(license MIT)

(package
 (name bearbeer)
 (synopsis "hackable blogging engine")
 (description "Minimal boilerplate blogging engine")
 (depends ocaml containers dream omd tyxml yaml ppx_deriving_yaml cmdliner))
