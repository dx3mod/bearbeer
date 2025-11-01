# Contributing

For develop the project we using some OCaml (>= 5.0 version), Dune build system, OCamlFormat for formatting source code and OPAM package manager for management external dependencies.

## Building the project

First, clone the project to your local machine.
```console
git clone https://github.com/dx3mod/bearbeer.git
```

Secondly, install the project dependencies using the package manager.
```console
opam install . --deps-only
```

Third, build already the project and go to develop this shit.
```console
dune build
```

## Internal documentations

Documented code is good code. Write clear and useful documentation comments, and avoid writing incorrect ones.

```console
$ dune build @doc @doc-private
$ open _build/default/_doc/_html/
```

## Developing guideline

This is a small project, so you can simply push your commits to the master branch without causing any confusion. But before always format your codes.

```console
$ dune fmt
$ dune build @check
```

```console
$ git add -A
$ git commit -m "your pretty changes" 
$ git push
```
