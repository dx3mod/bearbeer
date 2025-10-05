# bearbeer

It's minimal boilerplate blogging engine inspired by [deno_blog] and
[Bear Blog], written in [OCaml]. LOL.

## Installation

Now you can get only upstream (developer branch) version using OPAM, building
from sources:

```
$ opam pin bearbeer.dev https://github.com/dx3mod/bearbeer.git
```

## Showcase

```
$ bearbeer --root-dir ~/myshitblog
```

![](https://i.ibb.co/7NVj6KTP/image.png)

```
$ cat ~/myshitblog/bearbeer.yml
```

```yaml
title: Михаил Л.
language: ru

links:
    - title: vk
      url: https://vk.com/dx3modd
    - title: github
      url: https://github.com/dx3mod
```

```
$ cat ~/myshitblog/index.md
```

```md
aka @dx3mod

Yоу! Меня зовут Михаил, мне 21 год, на данный момент живу где-то на Северном
Кавказе, где начинаю взрослую жизнь; увлекаюсь квази-функциональным
программированием (на OCaml) и написанием всяких нетривиальных вещей.

<img src="https://sun9-56.userapi.com/s/v1/ig2/Qtr0bWiZn_p_4CAtwD-QE7pkVLyUkgW9XkKlym49dxhEPxSrmCY762f9aq0HQzsaIICjhkOmHwMZ8Xw9mMz6QjJr.jpg?quality=95&as=32x32,48x48,72x72,108x108,160x160,240x240,360x360,480x480,540x540,640x640,720x720,1080x1080,1280x1280,1440x1440,2297x2297&from=bu&cs=2297x0" width="20%" />
```

[deno_blog]: https://github.com/denoland/deno_blog
[Bear Blog]: https://bearblog.dev/
[OCaml]: https://ocaml.org
