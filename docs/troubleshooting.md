# Troubleshooting

Fixes for errors we've actually hit in this environment.

## `error: unable to locate module 'std'`

Full symptom:

```
error: unable to locate module 'std'
error: 'std' is required for all normal mojo compiles.
```

**Cause:** `.pixi/envs/default/share/max/modular.cfg` bakes **absolute** paths
(e.g. `import_path = <prefix>/lib/mojo`) at install time, and is *not*
regenerated on later shell activations. If the devcontainer's mount point
differs from when the env was created — we saw `/workspace` baked while the real
mount was `/workspaces/mojo` — every path goes stale and the compiler can't find
`std.mojoc`.

**Fix** (rewrite the baked root to the real prefix; stays within pixi/conda):

```bash
sed -i -E "s#[^ =,;]*/\.pixi/envs/default#$CONDA_PREFIX#g" \
  .pixi/envs/default/share/max/modular.cfg
```

**Permanent guard:** keep `Containerfile`'s `WORKDIR` in sync with
`workspaceFolder` in `.devcontainer/devcontainer.json` (both `/workspaces/mojo`)
so a fresh `pixi install` bakes correct paths.

## `error: unable to locate module 'math'` (or `testing`, `python`, …)

Not a broken install — in this build the stdlib is namespaced under `std.`.
Use `from std.math import sqrt`, not `from math import sqrt`. See
[language-notes.md](language-notes.md).

## `cannot call function that may raise in a context that cannot raise`

Your `def main()` calls a raising API. Mark it `def main() raises:`. See
[language-notes.md](language-notes.md).

## Python interop aborts: `Py_Initialize` / `PyErr_GetRaisedException` / `Failed to load libpython from :`

A Python-interop program can't find a compatible CPython runtime to `dlopen`.
`MOJO_PYTHON_LIBRARY` is set automatically inside `pixi run` / `pixi shell` (via
`pixi.toml`), so `pixi run mojo run ...` works. You hit this when running a
**compiled binary directly** (`./pyintop`) in a bare shell, where the variable
is unset — Mojo then finds nothing (note the empty path in `from :`) or falls
back to an old system Python (`PyErr_GetRaisedException is not available`). Run
it via `pixi run ./pyintop`, or
`export MOJO_PYTHON_LIBRARY="$PWD/.pixi/envs/default/lib/libpython3.so"` first.
Full detail: [python-interop.md](python-interop.md).

## `mojo format` / `mblack` silently do nothing

The **same stale-path bug** as the `std` error, but in the **shebangs** of
generated wrapper scripts under `.pixi/envs/default/bin/` (`mblack`, the
`jupyter*` scripts, `idle3.14`, `pydoc3.14`). Their first line points at the old
`/workspace/.pixi/.../python3.14` interpreter, so they fail to launch — and
`mojo format`, which shells out to `mblack`, then formats nothing (no error).

**Fix** (rewrite the stale shebang root to the real prefix):

```bash
grep -rl '^#!/workspace/' .pixi/envs/default/bin/ | while read -r f; do
  sed -i "1s#/workspace/\.pixi#$PWD/.pixi#" "$f"
done
```

After this, `pixi run mojo format <file>` reformats correctly. Same permanent
guard as above (align `WORKDIR` with `workspaceFolder`).

## `ERROR file_io_posix.cc:152] open .../crashdb/pending/*.lock: File exists (17)`

Cosmetic noise from Crashpad (Mojo's bundled crash reporter), not a problem with
your program or the current run — your actual output (e.g. `Hello, World!`)
still printed correctly. It happens when an **earlier** run crashed (commonly a
Python-interop binary run without `MOJO_PYTHON_LIBRARY`, see above) and left a
crash report queued; the next `mojo run` trips over a stale lock file while
filing it. Safe to clear (all under gitignored `.pixi/`):

```bash
rm -rf .pixi/envs/default/share/max/crashdb/{new,pending,completed,attachments}/*
```

## Env seems corrupt / weird resolution

Rebuild it clean (the env lives in the repo, so it persists across container
rebuilds):

```bash
rm -rf .pixi && pixi install
```
