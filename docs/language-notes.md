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
