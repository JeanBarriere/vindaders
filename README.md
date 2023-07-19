# V-Invaders

Invaders is an open source terminal arcade game with audio, based off of the "Space Invaders" classic arcade game.
V-Invaders is based from [CleanCut/invaders](https://github.com/CleanCut/invaders) but written in Vlang.

# Intro

❗️ V GC default mode (`boehm_full_opt`) is sometimes throwing a thread error. Use `boehm_full` to fix.

# Build

You can build `vinvaders` by running:

```
v -gc boehm_full .
```

# Run

```
v -gc boehm_full run .
```

# Original README notes

This game was initially developed for a presentation at [OSCON Open Source Software Superstream Series: Live Coding—Go, Rust, and Python](https://learning.oreilly.com/live-training/courses/oscon-open-source-software-superstream-series-live-codinggo-rust-and-python/0636920410188/) and then adapted for inclusion as an example project for the [Ultimate Rust Crash Course](https://www.udemy.com/course/ultimate-rust-crash-course/?referralCode=AF30FAD8C6CCCC2C94F0). The tags `part-1`, `part-2`, etc. correspond to the various stages of the original presentation.

Since the original presentations, folks continue to tinker and improve the game. Feel free to fork this repository, make a change, and submit a pull request if you have a good idea!

## Contribution

All contributions are assumed to be dual-licensed under MIT/Apache-2.

## License

Distributed under the terms of both the MIT license and the Apache License (Version 2.0).

See [license/APACHE](license/APACHE) and [license/MIT](license/MIT).
