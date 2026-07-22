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

## No `lambda` — use a nested `def`, with `capturing` (or `@parameter`) to capture

There is no `lambda` keyword. The compiler's own error is explicit:

```
error: lambda expressions are not supported; define a nested function with 'def'
```

(`lambda` did exist very early in Mojo's history — Context7's indexed archive
of a 2023 release note still shows it — but it's long gone from this build.)

A plain nested `def` works as a local helper, but **cannot** see variables
from the enclosing function — that fails with `Could not infer capture
convention of the captured value <name>`. There are **two ways** to make it a
real capturing closure, both verified to give identical results:

```mojo
def main():
    def add_one(x: Int) -> Int:          # plain nested def — no outer access
        return x + 1
    print(add_one(5))                    # 6

    var n = 10

    # Option 1: the `capturing` function-effect keyword — goes right after
    # the parameter list, BEFORE the `->` return type (a common mistake is
    # putting it after the return type, which is a parse error).
    def add_n(x: Int) capturing -> Int:
        return x + n
    print(add_n(5))                      # 15

    # Option 2: the @parameter decorator — equivalent for this purpose.
    @parameter
    def add_n2(x: Int) -> Int:
        return x + n
    print(add_n2(5))                     # 15
```

**Current limitation (still true either way):** a capturing closure can't be
assigned to a variable or passed around as a plain runtime value —
`var f = add_n` fails with `TODO: capturing closures cannot be materialized
as runtime values`. It's usable immediately, though, including as a
compile-time argument to a higher-order function that declares a matching
parameter type:

```mojo
def use_closure[func: def(Int) capturing [_] -> Int](num: Int) -> Int:
    return func(num)

def main():
    var x = 1
    @parameter
    def add(i: Int) -> Int:
        return x + i
    print(use_closure[add](2))           # 3
```

So it's not yet a first-class value the way a Python closure is — but it's
more usable than "capture, then immediately call" alone.

## String slicing needs `byte=`/`codepoint=` — and codepoint-slicing multi-byte text is buggy here

`s[a:b]` does **not** work directly on a `String`:

```
error: String does not support direct positional slicing like `s[a:b]`
because Mojo strings are UTF-8 encoded, and the same range can mean
different things. Use `s[byte=a:b]` to slice by raw UTF-8 byte positions,
or `s[codepoint=a:b]` to slice by Unicode code points.
```

Both explicit forms work:

```mojo
var s: String = "hello world"
print(s[byte=0:5])        # hello
print(s[codepoint=6:11])  # world
```

**Verified bug in this build:** `codepoint=` slicing a string that contains
any multi-byte character corrupts the result. `"café"` is 4 codepoints / 5
bytes (é is 2 bytes); `"café"[codepoint=0:4]` (the *entire* string) returns a
value with `byte_length() == 4` instead of `5` — a byte of the é got dropped,
and it prints as a mangled replacement character. Pure-ASCII text is
unaffected (1 byte == 1 codepoint there, so the bug can't manifest). Prefer
`byte=` slicing when correctness with non-ASCII content matters.

## No f-strings — use `t"..."` (template strings) instead

`f"..."` is a parse error in this build. The interpolation equivalent uses a
**`t` prefix**:

```mojo
var name: String = "World"
print(t"Hello, {name}!")     # Hello, World!
print(t"1 + 1 = {1 + 1}")    # 1 + 1 = 2
```

Two things to know:

- **`t"..."` does NOT implicitly convert to `String`.** It produces a distinct
  `TString[...]` type — `var s: String = t"n={n}"` fails with `cannot
  implicitly convert 'TString[...]' value to 'String'`. Wrap it explicitly:
  `String(t"n={n}")` (this is also why it works fine directly inside `print(...)`
  or concatenated with `+ String(...)`, without a separate conversion step).
- **No Python-style format specs.** `t"{x:.2f}"` is explicitly rejected:
  `format specifiers are not supported in t-strings; format the value
  manually before interpolating`. Precision/width formatting has to happen
  before interpolation, not inside the `{...}`.

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
