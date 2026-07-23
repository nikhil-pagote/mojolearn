---
title: pixi Cheatsheet
description: Quick reference for pixi commands in this Mojo workspace, tested with pixi 0.73.0.
---

# pixi Cheatsheet

Quick reference for this Mojo workspace. Tested with **pixi 0.73.0**.
Run everything **inside the devcontainer** — `mojo`/`pixi` are not on the host.

> This project's manifest uses the current `[workspace]` table (not the older
> `[project]`). Dependencies come from Modular's conda channel + conda-forge:
>
> ```toml
> [workspace]
> channels = ["https://conda.modular.com/max", "conda-forge"]
> platforms = ["linux-64"]
>
> [dependencies]
> mojo = ">=1.0.0b2,<2"
> ```

---

## Installing pixi itself

Pixi isn't a system package — it's installed per-machine (or per-container) via
its own installer script. This is exactly what `.devcontainer/Containerfile`
does when the devcontainer is built:

```bash
curl -fsSL https://pixi.sh/install.sh | sh
```

This drops the `pixi` binary at `~/.pixi/bin/pixi` (confirmed:
`/root/.pixi/bin/pixi`, 0.73.0, ~76 MB — pixi is a single self-contained
executable, no runtime dependencies of its own). It's **not** on `PATH` by
default, so the Containerfile also adds:

```dockerfile
ENV PATH="/root/.pixi/bin:${PATH}"
```

Outside a devcontainer (e.g. setting up a plain machine), the installer adds
that same directory to `PATH` itself via your shell profile — you'd normally
just open a new shell afterward instead of exporting it manually.

Once installed, `pixi` is global and machine-wide — you don't reinstall it per
project. Everything below (`pixi init`, `pixi add`, `pixi run`, …) reuses this
one binary across as many Mojo (or non-Mojo) projects as you create.

---

## Starting a new Mojo project from scratch

This is how *this* repo's `pixi.toml`/`pixi.lock` were actually generated —
reproduced and verified step by step in a scratch directory before writing it
down here.

```bash
# 1. Scaffold the manifest, declaring BOTH channels up front.
#    Modular's channel is where the `mojo` package itself lives; conda-forge
#    supplies everything else it depends on. Order matters (first = priority).
pixi init -c https://conda.modular.com/max -c conda-forge my-mojo-project
cd my-mojo-project

# 2. Add the mojo package. This solves the dependency graph and writes
#    both pixi.toml (the constraint) and pixi.lock (the exact pinned versions).
pixi add mojo

# 3. Sync the environment (downloads everything pixi.lock pinned).
pixi install

# 4. Verify it actually works.
mkdir exercises
printf 'def main():\n    print("Hello, World!")\n' > exercises/01_hello.mojo
pixi run mojo run exercises/01_hello.mojo    # -> Hello, World!
```

**Why the channel flags are required at step 1, not optional:** `pixi add mojo`
does **not** auto-discover which channel provides `mojo` — if you run
`pixi init` with no `-c` flags (which defaults to `conda-forge` only) and then
`pixi add mojo`, it fails outright:
```
Error: Cannot solve the request because of: No candidates were found for mojo.
```
Modular's channel has to already be declared before `pixi add mojo` can find
the package. If you forgot it at init time, add it after the fact instead of
re-running init:
```bash
pixi workspace channel add https://conda.modular.com/max
```

**`pixi init` also has a `--format mojoproject` option** (creates
`mojoproject.toml` instead of `pixi.toml`) — tested, and its manifest content
is structurally identical to a plain `pixi.toml` (same `[workspace]`/`[tasks]`/
`[dependencies]` tables), it's just named differently, and it still needs the
`-c` channel flags — it does **not** default to including Modular's channel.
This repo intentionally uses the plain `pixi.toml` format.

`pixi init` (either format) also generates a starter `.gitignore` (ignoring
`.pixi/*` except `config.toml`) and `.gitattributes` (treating `pixi.lock` as a
binary/generated file for diffs) — this repo's copies of both files came from
that scaffolding, not hand-written.

---

## Environment lifecycle

| Command | What it does |
|---|---|
| `pixi install` | Sync the env from `pixi.lock` (runs automatically via `postCreateCommand`). |
| `pixi shell` | Drop into a shell with `mojo`/`pixi` on `PATH` (exit with `exit`). |
| `pixi run <cmd>` | Run one command inside the env without entering a shell. |
| `pixi clean` | Remove the `.pixi/envs` environments (rebuild with `pixi install`). |

The env lives in `.pixi/envs/default/` **inside the repo** — it persists across
container rebuilds. Nuke and recreate it with:

```bash
rm -rf .pixi && pixi install
```

---

## Running Mojo in this project

```bash
pixi run mojo run exercises/01_hello.mojo     # interpret/JIT and run
pixi run mojo build exercises/01_hello.mojo   # AOT compile → ./01_hello (needs clang)
./01_hello                                    # run the native binary
pixi run mojo --version                       # check the compiler version
```

Or enter a shell once and drop the `pixi run` prefix:

```bash
pixi shell
mojo run exercises/01_hello.mojo
```

---

## Managing dependencies

| Command | What it does |
|---|---|
| `pixi add <pkg>` | Add a conda dependency and update `pixi.toml` + `pixi.lock`. |
| `pixi add --pypi <pkg>` | Add a dependency from PyPI instead of conda. |
| `pixi remove <pkg>` | Remove a dependency. |
| `pixi update` | Update `pixi.lock` to the newest allowed versions. |
| `pixi update <pkg>` | Update just one package in the lock. |
| `pixi list` | List installed packages in the env. |
| `pixi tree` | Show the dependency tree. |

`pixi.lock` is the source of truth for reproducibility — **commit it** alongside
`pixi.toml`. Don't hand-edit the lock; let `pixi add`/`pixi update` regenerate it.

---

## Tasks (project scripts)

None are defined yet (`[tasks]` is empty). Define reusable commands so you can
`pixi run <name>` instead of retyping:

```bash
pixi task add hello "mojo run exercises/01_hello.mojo"
pixi run hello          # runs the task
pixi task list          # show defined tasks
pixi task remove hello  # delete a task
```

Tasks are stored in `pixi.toml` under `[tasks]` and are committed with the repo.

---

## Inspecting the setup

| Command | What it does |
|---|---|
| `pixi info` | Show env paths, platform, channels, cache location. |
| `pixi --version` | pixi version (this project: 0.73.0). |
| `pixi list --explicit` | Only the packages you explicitly added. |

---

## Global tools (outside this project)

`pixi global` installs CLI tools available everywhere, independent of any project:

```bash
pixi global install <tool>
pixi global list
pixi global uninstall <tool>
```

---

## Troubleshooting

**`error: unable to locate module 'std'`** — the Mojo/MAX config
(`.pixi/envs/default/share/max/modular.cfg`) has stale absolute paths, usually
after the container's mount point changed. Fastest refix:

```bash
sed -i -E "s#[^ =,;]*/\.pixi/envs/default#$CONDA_PREFIX#g" \
  .pixi/envs/default/share/max/modular.cfg
```

The permanent guard is keeping `Containerfile`'s `WORKDIR` in sync with
`workspaceFolder` in `.devcontainer/devcontainer.json` (both `/workspaces/mojo`)
so a fresh `pixi install` bakes correct paths.

**Env seems corrupt / weird resolution** — rebuild it clean:

```bash
rm -rf .pixi && pixi install
```
