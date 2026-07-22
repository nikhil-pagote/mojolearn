# Operators: arithmetic, comparison, logical, bitwise, and operator
# overloading on a custom struct.
# Run: pixi run mojo run exercises/17_operators.mojo


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
    # --- arithmetic ---
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

    # --- comparison ---
    print(
        5 == 5, 5 != 3, 5 < 3, 5 > 3, 5 <= 5, 5 >= 6
    )  # True True False True True False

    # --- logical --- (using variables — literal `True and False` etc. makes
    # the compiler constant-fold and warn about the "always known" result)
    var t = True
    var f = False
    print(t and f, t or f, not t)  # False True False

    # --- bitwise ---
    print(6 & 3, 6 | 3, 6 ^ 3, ~6, 1 << 3, 16 >> 2)  # 2 7 5 -7 8 4

    # --- augmented assignment ---
    var n = 10
    n += 5
    n -= 2
    n *= 2
    n //= 3
    print("augmented:", n)  # augmented: 8

    # --- operator overloading on a custom struct ---
    var a = Vec2(1, 2)
    var b = Vec2(3, 4)
    print(a + b)  # (4, 6)
    a += b
    print(a)  # (4, 6)
    print(-a)  # (-4, -6)
    print(a == Vec2(4, 6), a == b)  # True False
    print(Vec2(1, 1) < Vec2(3, 4))  # True
