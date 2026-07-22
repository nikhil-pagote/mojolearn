# Mojo has no `class` keyword ("classes are not supported yet" — verified in
# exercises/12_no_inheritance.mojo). Structs are Mojo's only user-defined
# type, and they DO have a rich constructor story — just via `__init__` on a
# `struct`, not a `class`. This covers: multiple constructor overloads,
# default argument values, @staticmethod factory functions (the "classmethod"
# equivalent), and @fieldwise_init for the common case.
# Run: pixi run mojo run exercises/11_struct_constructors.mojo


struct Point:
    var x: Int
    var y: Int

    # --- constructor overloading: multiple __init__ definitions, resolved
    # by argument count/types, same as overloading any other function. ---
    def __init__(out self, x: Int, y: Int):
        self.x = x
        self.y = y

    def __init__(out self, both: Int):  # Point(5) -> (5, 5)
        self.x = both
        self.y = both

    # --- @staticmethod: a "classmethod"-style named factory. Called on the
    # type itself (Point.origin()), not an instance. ---
    @staticmethod
    def origin() -> Point:
        return Point(0, 0)

    def describe(self) -> String:
        return "(" + String(self.x) + ", " + String(self.y) + ")"


struct Vector:
    var x: Int
    var y: Int

    # --- default argument values in a constructor ---
    def __init__(out self, x: Int = 0, y: Int = 0):
        self.x = x
        self.y = y


# --- @fieldwise_init: auto-generates a constructor from the field list,
# for the common case where you'd otherwise just write __init__ by hand. ---
@fieldwise_init
struct Pair:
    var first: Int
    var second: Int


def main():
    # Overloaded constructors
    var p1 = Point(3, 4)
    var p2 = Point(5)  # uses the single-arg overload
    print(p1.describe(), p2.describe())  # (3, 4) (5, 5)

    # Static factory method
    var p3 = Point.origin()
    print(p3.describe())  # (0, 0)

    # Default argument values
    var v1 = Vector()  # (0, 0)
    var v2 = Vector(y=7)  # (0, 7)
    print(v1.x, v1.y, v2.x, v2.y)  # 0 0 0 7

    # @fieldwise_init-generated constructor
    var pair = Pair(1, 2)
    print(pair.first, pair.second)  # 1 2
