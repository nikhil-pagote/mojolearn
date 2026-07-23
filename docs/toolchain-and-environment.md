---
title: Toolchain & Environment
description: How pixi, the devcontainer, and Mojo's toolchain fit together in this workspace.
status: verified
tags: [toolchain, pixi, devcontainer]
updated: 2026-07-22
---

# Toolchain & Environment

## Is Mojo a Python thing?

No. Mojo is a **natively compiled** language. Python's tooling only shows up as
the *delivery mechanism* and as an *optional interop feature* — not as a runtime
requirement.

What's actually on disk (inside `.pixi/envs/default/`):

```
bin/mojo              ← ~141 MB NATIVE compiler binary — this IS Mojo
lib/mojo/std.mojoc    ← precompiled standard library (native, not .py)
lib/python3.14/…      ← a CPython interpreter, present for (a) Mojo↔Python
                        interop and (b) thin wrapper/launcher scripts
```

Three separate places "Python" appears, and only the last is a real dependency
— an optional one:

| Where | Real dependency? |
|---|---|
| Install/packaging (conda, pip, pixi, `site-packages/mojo/`) | No — just delivery |
| Dev tooling (LSP launcher, Jupyter, formatter) | No — editor convenience |
| `from std.python import Python` in *your* code | Yes, but only if you use it |

Proof: a compiled `01_hello.mojo` links **no** `libpython` (`ldd` shows only
Mojo runtime + libc/libstdc++) and runs standalone. Details in
[python-interop.md](python-interop.md).

## Why conda/pixi (not uv)?

Deliberate: we stay on Mojo's **default** toolchain so docs, error messages, and
community answers all match our setup. Modular publishes `mojo` on its conda
channel (`https://conda.modular.com/max`), and `pixi` is a conda-ecosystem tool.

A first-class `mojo` **pip wheel** also exists (`pip install mojo`) and would work
with uv — but we chose not to use it. (Interesting aside: the wheel resolves
paths at runtime from `__file__`, which sidesteps the stale-path bug in
[troubleshooting.md](troubleshooting.md); the conda binary reads a static
`modular.cfg` instead.)

## The layers, as a picture

```
pixi / conda  ── installer (Python-world tool), just drops files into a folder
     │
     ▼
.pixi/envs/default/
     bin/mojo            ← native compiler = the language
     lib/mojo/std.mojoc  ← native stdlib
     lib/python3.14/…    ← CPython, for optional interop + wrappers
```

Mental model: you installed a **native compiler** that happens to be shipped
through Python's "app store" and can *optionally* call Python at runtime.

## Everyday commands

Run inside the devcontainer (`mojo`/`pixi` are not on the host):

```bash
pixi install                              # sync env from pixi.lock
pixi run mojo run exercises/01_hello.mojo # JIT run
pixi run mojo build exercises/01_hello.mojo -o hello && ./hello   # AOT native
pixi shell                                # drop into env, then use `mojo` directly
```

Full reference: `../PIXI_CHEATSHEET.md`.
