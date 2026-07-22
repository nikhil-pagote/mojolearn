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

Run it (CPython must be discoverable — see below):

```bash
LIBPY=$(find .pixi/envs/default/lib -maxdepth 1 -name 'libpython3*.so' | head -1)
MOJO_PYTHON_LIBRARY="$LIBPY" pixi run mojo run exercises/02_python_interop.mojo
# -> Python math.sqrt(2.0) = 1.4142135623730951
```

## The proof: the two binaries compared

| | `01_hello` (no Python) | `02_python_interop` (uses Python) |
|---|---|---|
| Binary size | 18 KB | 117 KB |
| `ldd` lists `libpython`? | No | **No** (neither links it) |
| Runs standalone? | Yes | No — `ABORT: symbol not found: Py_Initialize` |
| With CPython available? | n/a | Yes — works |

Key findings:

1. **Mojo never links `libpython` at build time** — it's absent from `ldd` for
   *both* binaries.
2. Interop loads CPython **dynamically at runtime via `dlopen`**, and only when
   the program actually uses it. `01_hello` never touches Python and runs as a
   pure native binary.
3. If a program uses interop but no `libpython` is discoverable at runtime, it
   aborts on `Py_Initialize`. Point Mojo at one with the `MOJO_PYTHON_LIBRARY`
   env var (our env has `libpython3.14.so`).

## Takeaway

A Mojo program is native code that carries **zero** Python weight unless you opt
into interop — the opposite of "heavily dependent on Python." Python is a
feature you reach for, not a runtime you're stuck with.
