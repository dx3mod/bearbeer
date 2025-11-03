<img width="170px" src="https://gist.githubusercontent.com/dx3mod/a85c97ccc27c3eed1a8ab1c2d9b69851/raw/88b521cd9eef6b429589d63fc60bc07f4cd4d4c4/bearbeer.svg">

# bearbeer

It's a minimal boilerplate blogging engine for programmers written in [OCaml]. It is designed to be lean, mean, and hackable for self-hosting purposes.
Was inspired by [deno_blog] and [Bear Blog] projects.

If you want to add something, just [fork it](./CONTRIBUTING.md) and go drink beer.

**Features**

- Opinionated style and project organization are done and done well
- Dead simple to use and configure with the help of lovely documentation
- Self-hosted and self-managed web server, or a static bundle
- Single static binary for easy deployment and packaging of your system
- And, yeah, it's written in OCaml, which must be the reason why.

## Installation

Now you can get only upstream (developer branch) version using OPAM, building
from sources:

```
$ opam pin bearbeer.dev https://github.com/dx3mod/bearbeer.git
```

## Motivation

Why not use a production-ready static site generator instead of writing another flimsy blogging engine?

I appreciate opinionated solutions, be it a formatter, a build system or anything else. They just have everything done and done right. Because I wrote a hackable blogging engine for true enthusiasts who are ready to explore and improve the programs they use.

## Quick Start

First, create your blog project allows next organization layout:
```
your-first-blog
├── bearbeer.yml
├── index.md
└── posts
    ├── first.md
    └── second.md
```

Configuration file `bearbeer.yml`:
```yaml
title: My First Blog
language: en
# avatar: <url>

links:
  - title: github
    url: https://github.com/user
  - title: twitter
    url: https://twitter.com/user
```

Second, run it!

```console
$ bearbeer --root-dir ./your-first-blog
```

## References

- Idea inspired by [deno_blog]
- Design inspired by [Bear Blog]

## License

The project is licensed under [the MIT License](./LICENSE), which allows for all permissions. Just use it and enjoy yourself without fear.

[deno_blog]: https://github.com/denoland/deno_blog
[Bear Blog]: https://bearblog.dev/
[OCaml]: https://ocaml.org