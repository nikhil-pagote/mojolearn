# Mojo Tutorial (beginner-friendly, verified on this build)

A hands-on introduction to Mojo, written for **Mojo 1.0.0b2 as installed in this
workspace**. Every code block here was compiled and run against *this* compiler
— the output shown is real.

> ⚠️ **Why not just follow modular.com docs?** This beta has moved ahead of most
> published tutorials. Several things you'll read online simply don't compile
> here (no `fn`, no `let`, no `@value`, stdlib under `std.`). This doc uses only
> what works today. There's a full diff table at the [end](#what-differs-from-online-docs).

---

## 0. How to run code

Everything runs inside the devcontainer:

```bash
pixi run mojo run exercises/01_hello.mojo          # compile + run (JIT)
pixi run mojo build exercises/01_hello.mojo -o hi  # native binary
./hi
```

Or `pixi shell` once, then just `mojo run ...`. See `../PIXI_CHEATSHEET.md`.

Every program needs a `main`:

```mojo
def main():
    print("Hello, World!")
```
```
Hello, World!
```

---

## 1. Variables

Declare with `var`. Types are optional (inferred) but you can annotate.

```mojo
def main():
    var x = 41          # inferred as Int
    var y: Int = 1      # explicit type
    x = x + y           # reassignable
    print(x)            # 42
```

There is **no `let`** in this build — use `var` for everything. If you assign a
variable but never read it, the compiler warns and suggests `_`.

---

## 2. Basic types

```mojo
def main():
    var i: Int = 42            # integer
    var f: Float64 = 3.5       # 64-bit float
    var b: Bool = True         # boolean
    var s: String = "Mojo"     # string

    print(i, f, b, s)          # 42 3.5 True Mojo
    print(f * 2)               # 7.0
    print(b, not b)            # True False
    print("hi " + s)           # string concat: hi Mojo
    print(s.byte_length())     # 4
```

### All supported scalar types

Beyond the everyday `Int`/`Float64`/`Bool`/`String` above, this build supports
the full set of fixed-width numeric types (verified against the compiler):

| Kind | Types |
|---|---|
| Signed integers | `Int` (machine word), `Int8`, `Int16`, `Int32`, `Int64`, `Int128`, `Int256` |
| Unsigned integers | `UInt` (machine word), `UInt8`, `UInt16`, `UInt32`, `UInt64`, `UInt128`, `UInt256` |
| Floating point | `Float16`, `Float32`, `Float64`, `BFloat16`, `Float8_e4m3fn` |
| Other | `Bool`, `String`, `Byte` (alias for `UInt8`) |

Bare literals default to a specific type: `var x = 42` infers `Int`; `var f =
3.5` infers `Float64`. Use an explicit annotation (`var x8: Int8 = 42`) for
anything else. All of these are exercised together in
`exercises/03_variables.mojo`.

`len(s)` also works on a `String`, but this build **warns**: `Using
String.__len__() is discouraged, prefer .byte_length() or .count_codepoints()`
— because "length" is ambiguous for text. They agree for plain ASCII, but
diverge for multi-byte characters: `"café".byte_length()` is `5` (é is 2 bytes
in UTF-8) while `"café".count_codepoints()` is `4` (4 visible characters). Pick
the one you actually mean. (`len()` on `List`/`Dict`/etc. does **not** warn —
this is a `String`-specific nudge.)

Build a string from mixed parts with `String(...)`:

```mojo
def main():
    print(String("x=", 42))    # x=42
```

---

## 3. Functions

Functions use `def`. **This build has no `fn`** — `def` is the only keyword,
and it fully supports type annotations and return types.

```mojo
def add(a: Int, b: Int) -> Int:
    return a + b

def main():
    print(add(2, 3))           # 5
```

### Default and keyword arguments

```mojo
def power(base: Int, exp: Int = 2) -> Int:
    var r = 1
    for _ in range(exp):
        r *= base
    return r

def main():
    print(power(3))            # 9   (exp defaults to 2)
    print(power(2, exp=5))     # 32  (keyword argument)
```

### Functions that can fail: `raises`

A function that might `raise` must be marked `raises`. Notably, **`main` is
non-raising by default** — mark it `main() raises:` when it calls fallible code.

```mojo
def risky(x: Int) raises -> Int:
    if x < 0:
        raise Error("negative")
    return x

def main() raises:
    print(risky(10))           # 10
```

(Full error handling with `try/except` is in [section 8](#8-error-handling).)

---

## 4. Control flow

```mojo
def grade(n: Int) -> String:
    if n >= 90:
        return "A"
    elif n >= 80:
        return "B"
    else:
        return "C"

def main():
    print(grade(95), grade(85), grade(50))   # A B C
```

Ternary expression, `while`, and `for` with `range`:

```mojo
def main():
    var x = 5
    print("big" if x > 3 else "small")       # big

    var i = 0
    while i < 3:
        i += 1

    var total = 0
    for k in range(5):        # 0,1,2,3,4
        total += k
    print(i, total)           # 3 10
```

---

## 5. Collections

### List

```mojo
from std.collections import List

def main():
    var xs = List[Int]()
    xs.append(1)
    xs.append(2)
    xs.append(3)
    print(len(xs), xs[0])     # 3 1

    for x in xs:              # iterate by value
        print(x)              # 1 / 2 / 3
```

A list literal also works and infers its element type:

```mojo
def main():
    var xs = [10, 20, 30]
    var s = 0
    for x in xs:
        s += x
    print(s)                  # 60
```

### Dict

Dictionary access can raise, so use it from a `raises` context:

```mojo
from std.collections import Dict

def main() raises:
    var d = Dict[String, Int]()
    d["a"] = 1
    d["b"] = 2
    print(d["a"], len(d))     # 1 2
```

### Optional — a value that may be absent

```mojo
from std.collections import Optional

def main():
    var o = Optional[Int](5)
    if o:                     # truthy when present
        print(o.value())      # 5
```

### Tuples

```mojo
def minmax(a: Int, b: Int) -> Tuple[Int, Int]:
    return (a, b) if a < b else (b, a)

def main():
    var t = minmax(9, 4)
    print(t[0], t[1])         # 4 9

    var lo, hi = minmax(9, 4)   # unpacking — one `var` covers the whole pattern
    print(lo, hi)             # 4 9
```

(Repeating `var` per name — `var lo, var hi = ...` — still runs, but this build
warns: `nested 'var' or 'ref' patterns are redundant, remove the outer
pattern`. A single `var` before the comma-separated names is enough.)

### Set

Unordered, unique elements — with `|` (union) and `&` (intersection):

```mojo
from std.collections import Set

def main():
    var a = Set[Int](1, 2, 3)
    var b: Set[Int] = {2, 3, 4}   # {...} set-literal syntax also works
    a.add(1)                      # duplicate — no effect
    print(len(a))                 # 3
    print(a | b)                  # {1, 2, 3, 4}
    print(a & b)                  # {2, 3}
```

### The rest of `std.collections`: Deque, Counter, InlineArray, LinkedList, BitSet

```mojo
from std.collections import Deque, Counter, InlineArray, LinkedList, BitSet

def main() raises:                # Deque's pop()/popleft() can raise
    var dq = Deque[Int]()
    dq.append(1)
    dq.appendleft(0)
    print(dq)                     # [0, 1]
    print(dq.popleft())           # 0

    var counts = Counter[String]()
    counts["a"] += 1
    counts["a"] += 1
    print(counts["a"])            # 2 — missing keys default to 0

    # InlineArray: fixed-size, stack-allocated. Needs `fill=` — a variadic
    # constructor like List's does NOT work.
    var arr = InlineArray[Int, 3](fill=0)
    arr[0] = 1
    print(arr[0], len(arr))       # 1 3

    var ll = LinkedList[Int]()
    ll.append(1)
    print(ll, len(ll))            # [1] 1

    var bs = BitSet[64]()         # fixed-capacity set of bit flags
    bs.set(3)
    print(bs.test(3), bs.test(4)) # True False
```

### Comprehensions

List, dict, and set comprehensions all work, with an optional `if` filter —
but see the note below: there are **no generators**. Runnable exercise:
`exercises/14_comprehensions.mojo`.

```mojo
def main():
    var squares = [n * n for n in range(5)]
    print(squares)                          # [0, 1, 4, 9, 16]

    var evens = [n for n in range(10) if n % 2 == 0]
    print(evens)                            # [0, 2, 4, 6, 8]

    var lookup = {n: n * n for n in range(4)}
    print(lookup)                           # {0: 0, 1: 1, 2: 4, 3: 9}

    var uniq = {n % 3 for n in range(6)}
    print(uniq)                             # {0, 1, 2}
```

**No generators in this build.** Neither generator expressions
(`(x for x in ...)`) nor generator functions (`yield`) are supported —
`(x for x in range(5))` fails with `expected ')' in parenthesized expression`,
and `yield` fails with `unexpected token in expression`. Comprehensions build
the whole collection eagerly; there's no lazy-iterator equivalent yet.

### Variant — Mojo's `Union` equivalent

There is no `Union` type by that name. The equivalent is a tagged union,
`Variant[T1, T2, ...]`, from `std.utils` — check the active type with
`.isa[T]()`, extract it with `v[T]`:

```mojo
from std.utils import Variant

def main():
    var v: Variant[Int, String] = 42
    if v.isa[Int]():
        print(v[Int])              # 42
    v = String("now a string")
    if v.isa[String]():
        print(v[String])           # now a string
```

---

## 6. Structs

Structs bundle data and behavior. Unlike Python classes, they're statically
typed and have fixed fields.

The easiest way to get a constructor is the **`@fieldwise_init`** decorator (this
replaces the old `@value` you'll see online — `@value` does **not** exist here):

```mojo
@fieldwise_init
struct Point:
    var x: Int
    var y: Int

def main():
    var p = Point(1, 2)       # constructor generated from the fields
    print(p.x, p.y)           # 1 2
```

Or write the constructor and methods yourself. The constructor takes `out self`;
read-only methods take `self`; mutating methods take `mut self`:

```mojo
@fieldwise_init
struct Counter:
    var n: Int

    def get(self) -> Int:     # read-only method
        return self.n

    def inc(mut self):        # mutates the struct
        self.n += 1

def main():
    var c = Counter(0)
    c.inc()
    c.inc()
    print(c.get())            # 2
```

A struct with no fields still needs an explicit constructor:

```mojo
struct Cat:
    def __init__(out self):
        pass
    def speak(self) -> String:
        return "meow"

def main():
    print(Cat().speak())      # meow
```

### More constructor patterns

`__init__` can be overloaded, take default values, and structs can have
`@staticmethod` factory functions (the closest thing to a "classmethod"):

```mojo
struct Point:
    var x: Int
    var y: Int

    def __init__(out self, x: Int, y: Int):     # overload 1
        self.x = x
        self.y = y

    def __init__(out self, both: Int):          # overload 2 — Point(5) -> (5, 5)
        self.x = both
        self.y = both

    @staticmethod
    def origin() -> Point:                      # named factory: Point.origin()
        return Point(0, 0)

def main():
    print(Point(3, 4).x, Point(5).x)   # 3 5
    print(Point.origin().x)            # 0
```

Default values work as you'd expect: `def __init__(out self, x: Int = 0):`.

### There are no classes, and structs cannot inherit from structs

```mojo
class Animal: ...
```
```
error: classes are not supported yet
```

```mojo
struct Dog(Animal):   # Animal is a struct, not a trait
```
```
error: structs only conform to traits or trait compositions; remove
the struct type from the conformance list
```

Both are compiler errors in this build — not a style choice, a hard
limitation. Mojo's answers to "reuse behavior across types" are:

- **Composition** ("has-a"): put one struct inside another as a field, and
  delegate to it explicitly. There's no automatic field/method inheritance.
- **Traits** ("can-do"): completely unrelated structs implement the same
  trait and work with the same generic code — see §7 below. No shared base
  type, no inherited implementation, just a shared contract.

```mojo
@fieldwise_init
struct Engine(Copyable, Movable):
    var horsepower: Int

@fieldwise_init
struct Car(Copyable, Movable):
    var engine: Engine       # composition: Car HAS an Engine
    var name: String

    def describe(self) -> String:
        return self.name + " (" + String(self.engine.horsepower) + " hp)"

def main():
    var e = Engine(300)
    var c = Car(e^, "Tesla")   # `^` transfers e — it isn't implicitly
    print(c.describe())        # copyable (see docs/language-notes.md)
    # -> Tesla (300 hp)
```

Runnable exercises: `exercises/15_no_inheritance.mojo` (composition + traits
as the inheritance substitute) and `exercises/16_struct_constructors.mojo`
(overloading, defaults, static factories, `@fieldwise_init`).

---

## 7. Traits and generics

A **trait** is a contract — a set of methods a type promises to provide (like a
Python ABC or a Rust trait). Use `...` for the method bodies in the trait:

```mojo
trait Greet:
    def hello(self) -> String: ...
```

A struct implements a trait by listing it in parentheses:

```mojo
@fieldwise_init
struct Dog(Greet):
    var name: String
    def hello(self) -> String:
        return self.name + " says woof"
```

**Generics** (Mojo calls these compile-time *parameters*, in square brackets) let
one function work for any type that satisfies a trait:

```mojo
def greet[T: Greet](t: T) -> String:
    return t.hello()

def main():
    print(greet(Dog("Rex")))  # Rex says woof
```

`greet` accepts *any* type implementing `Greet`, resolved at compile time (no
runtime cost).

---

## 8. Error handling

```mojo
def risky(x: Int) raises -> Int:
    if x < 0:
        raise Error("negative")
    return x

def main():
    try:
        print(risky(-1))
    except e:
        print("caught:", e)   # caught: negative
```

The rule to remember: anything that can `raise` must either be inside a
`try/except`, or be in a function itself marked `raises`.

### The rest of the toolkit: else, finally, bare except, re-raise

```mojo
def main():
    # else: runs only when the try block did NOT raise
    try:
        print(risky(5))
    except e:
        print("caught:", e)
    else:
        print("no exception occurred")

    # finally: always runs, exception or not
    try:
        raise Error("boom")
    except e:
        print("caught:", e)
    finally:
        print("cleanup always runs")

    # bare `except:` — catch-all, no variable
    try:
        raise Error("boom")
    except:
        print("caught something")
```

A bare `raise` (no argument) inside an `except` block re-raises the
currently-caught error — useful for "log it, then let the caller handle it
too":

```mojo
def inner() raises:
    raise Error("inner failure")

def outer() raises:
    try:
        inner()
    except:
        print("logging then re-raising")
        raise            # re-raises the same error
```

`except e:` binds an `Error` value — extract its message explicitly with
`String(e)` if you need a `String` rather than just printing it. `Error(...)`
also accepts multiple arguments, joined like `print()`/`String()`:
`Error("code=", 404, " not found")`.

---

## 9. A taste of performance: SIMD

Mojo exposes hardware SIMD (single-instruction-multiple-data) vectors as a
first-class type — one of the reasons it's fast. A `SIMD` value holds several
numbers and operates on all of them at once:

```mojo
def main():
    var v = SIMD[DType.int32, 4](1, 2, 3, 4)
    print(v * 2)              # [2, 4, 6, 8]  — all four lanes multiplied
```

`Int`, `Float64`, etc. are actually single-lane SIMD values under the hood.

---

## 10. Calling Python

Mojo can call any Python library as an opt-in feature. Full details and the
"is Mojo dependent on Python?" answer are in
[python-interop.md](python-interop.md). The short version:

```mojo
from std.python import Python

def main() raises:
    var math = Python.import_module("math")
    print("sqrt(2) =", math.sqrt(2.0))
```

Run it with CPython made discoverable:

```bash
LIBPY=$(find .pixi/envs/default/lib -maxdepth 1 -name 'libpython3*.so' | head -1)
MOJO_PYTHON_LIBRARY="$LIBPY" pixi run mojo run exercises/02_python_interop.mojo
```

---

## What differs from online docs

Quick reference for when a web tutorial won't compile here:

| Web tutorials use | This build (1.0.0b2) requires |
|---|---|
| `fn name(...)` | `def name(...)` — **`fn` removed entirely**, even for methods |
| `let x = ...` | `var x = ...` — **`let` removed** |
| `@value` on structs | `@fieldwise_init` |
| `from math import sqrt` | `from std.math import sqrt` (whole stdlib under `std.`) |
| `from python import Python` | `from std.python import Python` |
| `from testing import ...` | `from std.testing import ...` |
| `inout self` / `inout x` | `mut self` / `mut x` |
| `borrowed x` (immutable arg) | `read x` — and it's the default, so usually omit it |
| `owned x` (take ownership) | `var x` |

When in doubt, **verify against the installed compiler**, not the website — that's
the standing rule in this repo (`CLAUDE.md`).

---

## Runnable exercises

Each tutorial section has a matching, verified script under `exercises/` — run
any of them with `pixi run mojo run exercises/<file>`:

| File | Covers |
|---|---|
| `01_hello.mojo` | §0 hello world |
| `02_python_interop.mojo` | §10 calling Python |
| `03_variables.mojo` | §1–2 variables & all supported scalar types |
| `04_functions.mojo` | §3 functions, defaults, `raises` |
| `05_control_flow.mojo` | §4 if/elif/else, ternary, loops |
| `06_collections.mojo` | §5 List, Dict, Optional, tuples, Set, Deque, Counter, InlineArray, LinkedList, BitSet, Variant |
| `07_structs.mojo` | §6 structs, methods, `mut self` |
| `08_traits_generics.mojo` | §7 traits & generics |
| `09_error_handling.mojo` | §8 raise / try / except / else / finally / re-raise |
| `10_simd.mojo` | §9 SIMD |
| `11_string_operations.mojo` | String methods: case, strip, split/join, replace, find, slicing (`byte=`/`codepoint=`), length, `t"..."` interpolation |
| `12_file_operations.mojo` | File I/O: open/read/write/close, `with`, append mode, existence checks, error handling |
| `13_closures.mojo` | No `lambda`; capturing via `capturing` keyword or `@parameter`; closures as compile-time args |
| `14_comprehensions.mojo` | §5 list/dict/set comprehensions, `if` filters, no generators |
| `15_no_inheritance.mojo` | §6 no classes, no struct inheritance — composition + traits instead |
| `16_struct_constructors.mojo` | §6 `__init__` overloading, defaults, `@staticmethod` factories, `@fieldwise_init` |

## Next steps

- Tinker: change values in the exercises above and re-run them.
- When you build reusable structs/traits, move them into `src/mojolearn/`.
- For tests: `from std.testing import assert_equal` works; there's no `mojo test`
  subcommand yet, so run test scripts with `mojo run`. See
  [language-notes.md](language-notes.md).
- Hit an error? Check [troubleshooting.md](troubleshooting.md).
