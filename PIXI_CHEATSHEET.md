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
