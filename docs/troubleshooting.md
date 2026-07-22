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

## `ABORT: symbol not found: Py_Initialize`

A program using Python interop can't find a CPython runtime to `dlopen`. Set
`MOJO_PYTHON_LIBRARY` to the env's libpython. See
[python-interop.md](python-interop.md).

## Env seems corrupt / weird resolution

Rebuild it clean (the env lives in the repo, so it persists across container
rebuilds):

```bash
rm -rf .pixi && pixi install
```
