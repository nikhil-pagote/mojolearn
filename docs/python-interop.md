# Python Interop (and why Mojo is *not* Python-dependent)

Mojo can call into CPython — NumPy, pandas, any Python library — as a feature.
But the dependency is **runtime-only and pay-per-use**, proven below.

## Minimal example

`exercises/02_python_interop.mojo`:

```mojo
from std.python import Python

def main() raises:
    var math = Python.import_module("math")
    print("Python math.sqrt(2.0) =", math.sqrt(2.0))
```

Run it:

```bash
pixi run mojo run exercises/02_python_interop.mojo
# -> Python math.sqrt(2.0) = 1.4142135623730951
```

This works because `MOJO_PYTHON_LIBRARY` is set automatically inside the pixi
environment — see [Configuration](#configuration) below.

## Why a CPython interpreter must be present at runtime

The mental model that explains every error in this doc:

> Mojo **compiles your Mojo code** to native machine code — *including* the code
> that calls Python. But the Python things you call (`math.sqrt`, a NumPy array)
> are Python objects, and **Python is interpreted** — only CPython knows how to
> execute them. Mojo cannot compile arbitrary Python into your binary, so it
> emits native code that, at runtime, hands those calls to a real CPython
> interpreter through its C-API (`Py_Initialize`, `PyObject_CallMethod`, …).

That interpreter ships as a shared library — **`libpython`** — which Mojo
`dlopen`s **on demand**, only if the program actually uses interop. So the Python
parts of your program aren't compiled; they're *executed by an embedded CPython*
at run time. That is the whole reason a Python-interop binary must be able to
find `libpython`.

## The proof: the two binaries compared

| | `01_hello` (no Python) | `02_python_interop` (uses Python) |
|---|---|---|
| Binary size | 18 KB | 117 KB |
| `ldd` lists `libpython`? | No | **No** (neither links it) |
| Runs standalone? | Yes | No — needs a CPython runtime |
| With CPython available? | n/a | Yes — works |

Key findings:

1. **Mojo never links `libpython` at build time** — it's absent from `ldd` for
   *both* binaries.
2. Interop loads CPython **dynamically at runtime via `dlopen`**, and only when
   the program actually uses it. `01_hello` never touches Python and runs as a
   pure native binary.
3. If a program uses interop but no (compatible) `libpython` is discoverable at
   runtime, it aborts — either `symbol not found: Py_Initialize`, or (if it falls
   back to an old system Python) `PyErr_GetRaisedException is not available in
   this Python version`. The fix is to point Mojo at the env's CPython 3.14 via
   `MOJO_PYTHON_LIBRARY`.

## Running a compiled interop binary

`mojo build` produces a native binary, but a Python-interop binary still needs
CPython at run time. **Only interop binaries need this** — pure-Mojo binaries
(like `01_hello`) run anywhere with no pixi and no Python.

```bash
pixi run mojo build exercises/02_python_interop.mojo -o pyintop
```

Three ways to run `./pyintop`:

```bash
# 1. Through pixi — simplest; the env sets MOJO_PYTHON_LIBRARY for you
pixi run ./pyintop

# 2. Inside a pixi shell — enter once, then run normally
pixi shell
./pyintop

# 3. Bare shell — set the variable yourself (run from the project root)
export MOJO_PYTHON_LIBRARY="$PWD/.pixi/envs/default/lib/libpython3.so"
./pyintop
```

Running `./pyintop` in a plain shell with the variable **unset** is what
produces the `Failed to load libpython from :` abort (note the empty path) — the
setup is fine, the binary just can't find its interpreter. Contrast:

```bash
pixi run mojo build exercises/01_hello.mojo -o hello
./hello        # runs anywhere — no pixi, no Python, fully standalone
```

## Configuration

`MOJO_PYTHON_LIBRARY` is set two complementary ways:

1. **`pixi.toml`** — for `pixi run` / `pixi shell` (portable, env-relative):
   ```toml
   [activation.env]
   MOJO_PYTHON_LIBRARY = "$CONDA_PREFIX/lib/libpython3.so"
   ```
2. **`.devcontainer/Containerfile`** — a global `ENV` so even a bare `./binary`
   in a plain shell finds CPython:
   ```dockerfile
   ENV MOJO_PYTHON_LIBRARY="/workspaces/mojo/.pixi/envs/default/lib/libpython3.so"
   ```
   (Literal path — `$PWD` does **not** expand in a Dockerfile `ENV`. It's stable
   because `WORKDIR` == `workspaceFolder`.)

`libpython3.so` is the version-agnostic symlink to the bundled CPython 3.14.

**Caveat:** the Containerfile `ENV` only takes effect on the next **container
rebuild**. In your *current* shell it isn't set globally yet, so either use
`pixi run ./binary` or `export MOJO_PYTHON_LIBRARY=...` by hand until you rebuild.

## Takeaway

A Mojo program is native code that carries **zero** Python weight unless you opt
into interop — the opposite of "heavily dependent on Python." When you *do* opt
in, the Python half runs on an embedded CPython interpreter loaded at run time.
Python is a feature you reach for, not a runtime you're stuck with.
