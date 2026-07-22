# Closures: no `lambda` in this build — nested `def` is the substitute, and
# capturing an outer variable needs either `capturing` or `@parameter`.
# See docs/language-notes.md for the full writeup (incl. what Context7's docs
# got right, and where they mixed in outdated syntax).
# Run: pixi run mojo run exercises/14_closures.mojo


# A capturing closure can be passed into another function at COMPILE TIME via
# this parameter-type syntax (note: `def(...)`, not the old `fn(...)`).
def use_closure[func: def(Int) capturing[_] -> Int](num: Int) -> Int:
    return func(num)


def main():
    # --- plain nested def: fine as a local helper, but sees nothing outside
    # itself. Referencing an outer variable here is a compile error. ---
    def add_one(x: Int) -> Int:
        return x + 1

    print(add_one(5))  # 6

    var n = 10

    # --- Option 1: `capturing` function-effect keyword — goes right after
    # the parameter list, BEFORE the `->` return type. (Putting it after the
    # return type instead is a parse error — an easy mistake to make.) ---
    def add_n(x: Int) capturing -> Int:
        return x + n

    print(add_n(5))  # 15

    # --- Option 2: @parameter decorator — equivalent to `capturing` here. ---
    @parameter
    def add_n2(x: Int) -> Int:
        return x + n

    print(add_n2(5))  # 15

    # --- Using a capturing closure as a compile-time argument to another
    # function (see use_closure's signature above). ---
    var x = 1

    @parameter
    def add_x(i: Int) -> Int:
        return x + i

    print(use_closure[add_x](2))  # 3

    # --- Current limitation: a capturing closure can't be assigned to a
    # variable / stored as a plain runtime value.
    #   var f = add_n2   # error: TODO: capturing closures cannot be
    #                     # materialized as runtime values
    # It's usable immediately (as above), just not yet a first-class value
    # the way a Python closure is.
