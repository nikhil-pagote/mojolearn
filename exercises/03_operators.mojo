# Operators, in logical groups: arithmetic -> comparison (incl. `in`, `is`,
# which Python treats as the same category) -> boolean logic (incl.
# short-circuit) -> bitwise -> augmented assignment -> operator overloading
# on a custom struct.
# Run: pixi run mojo run exercises/03_operators.mojo

from std.collections import Dict, Optional


@fieldwise_init
struct Vec2(Copyable, Movable, Writable):
    var x: Int
    var y: Int

    def __add__(self, other: Vec2) -> Vec2:
        return Vec2(self.x + other.x, self.y + other.y)

    def __iadd__(mut self, other: Vec2):  # backs `+=`
        self.x += other.x
        self.y += other.y

    def __neg__(self) -> Vec2:  # backs unary `-`
        return Vec2(-self.x, -self.y)

    def __eq__(self, other: Vec2) -> Bool:
        return self.x == other.x and self.y == other.y

    def __lt__(self, other: Vec2) -> Bool:  # order by squared length
        return (self.x * self.x + self.y * self.y) < (
            other.x * other.x + other.y * other.y
        )

    # Making a struct printable does NOT use Python's __str__/Stringable —
    # `Stringable` isn't even a resolvable name in this build. The real
    # mechanism is the `Writable` trait + a `write_to` method.
    def write_to[W: Writer](self, mut writer: W):
        writer.write("(", self.x, ", ", self.y, ")")


def main():
    # ============================================================
    # 1. ARITHMETIC
    # ============================================================
    print(7 + 3, 7 - 3, 7 * 3, 7 // 3, 7 % 3, 2**3)  # 10 4 21 2 1 8

    # `/` between two Int values TRUNCATES to an Int in this build — unlike
    # Python, where `/` always produces a float. This is a real, silent-bug
    # trap if you're expecting Python's semantics.
    print("7 / 3 (Int/Int):", 7 / 3)  # 7 / 3 (Int/Int): 2
    # Force true division by converting to Float64 first:
    print(
        "true division:", Float64(7) / Float64(3)
    )  # true division: 2.3333333333333335

    # Floor division and modulo round toward -infinity, matching Python
    # (not C's truncate-toward-zero):
    print(-7 // 3, -7 % 3)  # -3 2

    # ============================================================
    # 2. COMPARISON — Python treats ==, !=, <, >, in, is (and their
    # negations) as the same operator category/precedence; grouped that
    # way here too, rather than splitting `in`/`is` off into "logical".
    # ============================================================
    print(
        5 == 5, 5 != 3, 5 < 3, 5 > 3, 5 <= 5, 5 >= 6
    )  # True True False True True False

    # --- membership: `in` / `not in` work the same way across every
    # collection — String (substring), List, Set (element), Dict (KEY,
    # like Python — not value). ---
    var text: String = "hello world"
    var xs = [1, 2, 3]
    var lookup = Dict[String, Int]()
    lookup["a"] = 1
    print("world" in text, "xyz" not in text)  # True True
    print(2 in xs, 5 in xs)  # True False
    print("a" in lookup, "z" in lookup)  # True False

    # --- identity: `is` / `is not` — narrower than Python's. Python's `is`
    # works on any object. Here it only works for types that implement
    # `__is__` (e.g. Optional's `is None` check); plain value types like Int
    # don't implement it at all (`'Int' does not implement the '__is__'
    # method` — not a runtime False, a compile error). ---
    var maybe: Optional[Int] = None
    print(maybe is None)  # True

    # ============================================================
    # 3. BOOLEAN LOGIC — combines the comparison results above.
    # (using variables — literal `True and False` etc. makes the compiler
    # constant-fold and warn about the "always known" result)
    # ============================================================
    var t = True
    var f = False
    print(t and f, t or f, not t)  # False True False

    # `and`/`or` return the actual VALUE, not a coerced Bool — same as
    # Python, and short-circuit (the right side is skipped once the result
    # is already known).
    var zero = 0
    var five = 5
    print(zero or five)  # 5  (not True/False)

    def noisy(label: String, val: Bool) -> Bool:
        print("  evaluated:", label)
        return val

    print("short-circuit and:")
    _ = noisy("left", False) and noisy("right", True)  # only "left" prints
    print("short-circuit or:")
    _ = noisy("left", True) or noisy("right", True)  # only "left" prints

    # ============================================================
    # 4. BITWISE
    # ============================================================
    print(6 & 3, 6 | 3, 6 ^ 3, ~6, 1 << 3, 16 >> 2)  # 2 7 5 -7 8 4

    # ============================================================
    # 5. AUGMENTED ASSIGNMENT
    # ============================================================
    var n = 10
    n += 5
    n -= 2
    n *= 2
    n //= 3
    print("augmented:", n)  # augmented: 8

    # ============================================================
    # 6. OPERATOR OVERLOADING — putting the categories above to use on a
    # custom type (see Vec2 above: __add__, __iadd__, __neg__, __eq__,
    # __lt__, and Writable/write_to for printing).
    # ============================================================
    var a = Vec2(1, 2)
    var b = Vec2(3, 4)
    print(a + b)  # (4, 6)
    a += b
    print(a)  # (4, 6)
    print(-a)  # (-4, -6)
    print(a == Vec2(4, 6), a == b)  # True False
    print(Vec2(1, 1) < Vec2(3, 4))  # True

    # ============================================================
    # 7. TRANSFER (^) — postfix, applies to a single variable; NOT the same
    # `^` as the bitwise XOR in section 4 above (infix, between two
    # expressions). Operand shape disambiguates them.
    # ============================================================

    # Plain `b = a` (no `^`) COPIES — the source keeps its value.
    var s1: String = "hello"
    var s2 = s1
    print(s1, s2)  # hello hello — s1 untouched

    # `b = a^` TRANSFERS ownership instead of copying. Two cases, neither
    # left runnable here (the first WARNS, the second fails to COMPILE —
    # both would break this exercise's zero-warnings-clean convention):
    #
    # Trivial register type (Int) — transfer is a no-op, source stays
    # usable, compiler just warns it had no effect:
    #
    #   var i1 = 10
    #   var i2 = i1^
    #   print(i1, i2)  # 10 10 — i1 still valid
    #   # warning: transfer from a value of trivial register type 'Int'
    #   #          has no effect and can be removed
    #
    # Resource-owning type (String, Vec2, ...) — `^` is an enforced,
    # compile-time move: using the source again afterward is a COMPILE
    # ERROR (`use of uninitialized value`), not a runtime deletion:
    #
    #   var s3: String = "world"
    #   var s4 = s3^
    #   print(s4)   # world
    #   print(s3)   # error: use of uninitialized value 's3'
    #
    # See docs/mojo-training-slides.html Session 5 for the full writeup on `^`.
