---
title: CLAUDE.md
description: Guidance for Claude Code when working with code in this repository.
status: reference
tags: [claude-code, project-conventions]
updated: 2026-08-13
---

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status

This is a Mojo learning workspace, developed inside a devcontainer (podman-based) rather than on the host. Broad tutorial/quickstart notes live outside this repo, in the Obsidian vault at `Developer/Mojo/Quickstart.md` and `Developer/Mojo/Tutorial.md`. Verified, repo-specific findings (things confirmed against *this* environment) live in-repo under `docs/` — start at `docs/README.md`.

## Environment

- Mojo/pixi are only installed inside the devcontainer (`.devcontainer/Containerfile` + `devcontainer.json`) — not on the host.
- The container is plain Ubuntu 24.04 + `pixi` (installed via curl) + `clang` (required for `mojo build`'s linking step — `mojo run` doesn't need it, but AOT `mojo build` does).
- `pixi.toml`/`pixi.lock` were generated inside the container with `pixi init` + `pixi add mojo`, not hand-written — the `[workspace]` table (not `[project]`) is current pixi (0.73.0) schema.

## Commands

Run inside the devcontainer:
- `pixi install` — sync the environment from `pixi.lock` (also runs automatically via `postCreateCommand`).
- `pixi run mojo run <file>.mojo` — run a Mojo source file directly.
- `pixi run mojo build <file>.mojo && ./<file>` — compile to a native binary and run it.
- `pixi shell` — drop into a shell with `mojo`/`pixi` on `PATH`, so you can call `mojo` directly instead of prefixing `pixi run`.

## Project structure

```
mojo/
├── docs/            # verified, repo-specific learning notes (start at README.md)
├── exercises/       # one runnable script per tutorial topic, e.g. 01_hello.mojo
├── src/mojolearn/   # shared package code, once exercises produce reusable structs/traits
│   └── __init__.mojo
├── tests/           # empty for now — see note below
└── PIXI_CHEATSHEET.md
```

- `exercises/*.mojo` are standalone scripts with `def main()`, run via `mojo run exercises/NN_name.mojo`. Numbered loosely after the Tutorial.md chapters.
- **Stdlib imports are namespaced under `std.` in this build** (Mojo 1.0.0, confirmed unchanged from 1.0.0b2): use `from std.math import sqrt`, `from std.python import Python`, `from std.testing import assert_equal`. Bare forms like `from math import ...` (common in online docs/tutorials) fail here with `unable to locate module '<name>'`. Builtins like `print` need no import. Also: `def main()` is non-raising by default — use `def main() raises:` when calling fallible APIs (e.g. `Python.import_module`). Working example: `exercises/17_python_interop.mojo`.
- `src/mojolearn/` follows the Python-style package convention (`__init__.mojo` marks a directory as a package, imported as `from mojolearn import Thing`). Empty until there's real shared code to put there — don't add modules speculatively.
- `tests/` — the stdlib **does** ship a `testing` module; the correct import is `from std.testing import assert_equal` (the earlier failure was the bare `from testing import ...` form — see the `std.` namespace note above). There is still **no `mojo test` subcommand** in this CLI (confirmed via `mojo --help` on 1.0.0), so a test today is a standalone `.mojo` script with `def main() raises:` that calls `assert_*` and is run via `mojo run`. Build out a fuller convention when tests are actually needed.
- **List literals changed in 1.0.0:** a bare `[1, 2, 3]` now infers `Array[Int, N]`, not `List[Int]` — annotate the target (`var xs: List[Int] = [1, 2, 3]`) whenever you actually need a `List`. Bit us in `exercises/14_closures.mojo`.
