# Language Notes (verified on Mojo 1.0.0b2, this build)

These differ from a lot of online material, which targets other versions.

## Stdlib imports are namespaced under `std.`

In this build, standard-library modules live under a `std.` prefix:

```mojo
from std.math import sqrt
from std.collections import List
from std.python import Python
from std.testing import assert_equal
```

The **bare** forms you'll see in most tutorials fail here:

```mojo
from math import sqrt        # error: unable to locate module 'math'
from testing import ...      # error: unable to locate module 'testing'
from python import Python     # error: unable to locate module 'python'
```

Builtins (`print`, `def`, `main`, basic types) need no import at all.

How we found this: every bare stdlib import failed with `unable to locate
module '<name>'`, while `print`/`main` worked. Since the compiler insists
`'std' is required for all normal mojo compiles` and the package is literally
named `std`, we tried the `std.` prefix — and every module resolved.

## Every program needs `def main()` — no top-level code

Unlike a Python script (which runs top-to-bottom, so a bare `print("hi")`
executes), a `.mojo` file compiled or run with `mojo run` / `mojo build` has a
single entry point: **`def main()`**. Execution starts there, like `main()` in
C/C++/Rust.

Executable statements are **not allowed at file scope at all** — not even
alongside a `main`:

```mojo
print("hi")        # error: expressions must not appear at file scope;
                   #        move this into a function body
```

File scope is for *declarations only* (`def`, `struct`, `trait`, `alias`,
`from ... import`). Put runnable code inside a function:

```mojo
def main():
    print("hi")    # ✅
```

(The REPL — `mojo repl` — and notebook cells *do* evaluate statements
interactively; this rule is about `.mojo` source files.)

## `def main()` is non-raising by default

Calling a fallible (raising) API from a plain `def main()` is a compile error:

```
error: cannot call function that may raise in a context that cannot raise
```

Mark the function `raises`:

```mojo
def main() raises:
    var m = Python.import_module("math")   # import_module can raise
```

## `len()` on `String` is discouraged — use `byte_length()`/`count_codepoints()`

```
warning: Using String.__len__() is discouraged, prefer .byte_length() or .count_codepoints()
```

`len(s)` still compiles and returns a value, but this build actively warns on
it for `String` because "length" is ambiguous for text:

```mojo
var s: String = "café"
print(s.byte_length())        # 5  — UTF-8 bytes (é is 2 bytes)
print(s.count_codepoints())   # 4  — visible characters
```

The two agree for plain ASCII (which is why `len()` "looks fine" until you hit
non-ASCII text). This warning is **`String`-specific** — `len()` on `List`,
`Dict`, etc. does not warn.

## There is no runtime `type()` — types are a compile-time thing

Python's `type(x)` is a **runtime** call: it inspects a live object and returns
a type object you can print, compare, or store. Mojo is statically typed —
every variable's type is fixed at **compile time**, so there's no runtime
registry of "what type is this value" to query, and no `isinstance()` either
(`use of unknown declaration 'isinstance'`).

The closest equivalent is the builtin **`type_of(x)`**, but it's a
*compile-time* type expression (like C++'s `decltype`), not a runtime value —
you can't `print()` it or convert it with `String(...)`:

```mojo
def main():
    var x = 42
    print(type_of(x))          # error: could not convert ... to 'Writable'
```

Its real use is as a type **annotation**, so you can name "the same type as
this other variable" without hardcoding it:

```mojo
def main():
    var x: Int = 42
    var y: type_of(x) = 10     # y's type is inferred from x's type
    print(y)                   # 10
```

**If you specifically need a printable type name at runtime** (e.g. for
debug output), that's a job for Python interop, not Mojo's own type system —
Python's real `type()` still works on a `PythonObject`:

```mojo
from std.python import Python

def main() raises:
    var builtins = Python.import_module("builtins")
    var x = Python.evaluate("42")
    print(builtins.type(x))    # <class 'int'>
```

## Testing

The `testing` module exists here as `from std.testing import assert_equal`.
There is **no `mojo test` subcommand** in this CLI (confirmed via `mojo --help`),
so a "test" today is just a standalone script:

```mojo
from std.testing import assert_equal

def main() raises:
    assert_equal(1 + 1, 2)
    print("ok")
```

Run it with `pixi run mojo run tests/whatever.mojo`. Build a fuller convention
only when tests are actually needed.
