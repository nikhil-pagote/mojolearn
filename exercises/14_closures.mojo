# Closures: no `lambda` in this build — nested `def` is the substitute, and
# capturing an outer variable needs either `capturing` or `@parameter`.
# See docs/mojo-training-slides.html Session 4 for the full writeup.
# Run: pixi run mojo run exercises/14_closures.mojo

from std.collections import List


# A capturing closure can be passed into another function at COMPILE TIME via
# this parameter-type syntax (note: `def(...)`, not the old `fn(...)`).
def use_closure[func: def(Int) capturing[_] -> Int](num: Int) -> Int:
    return func(num)


# --- Custom example: a generic filter that accepts ANY predicate closure as
# a compile-time parameter. `filter_list` doesn't know or care what the
# closure captured — it just calls `pred(x)` for each element. ---
def filter_list[
    pred: def(Int) capturing[_] -> Bool
](xs: List[Int]) -> List[Int]:
    var result = List[Int]()
    for x in xs:
        if pred(x):
            result.append(x)
    return result^


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

    # --- Custom example 1: closures aren't read-only — a capturing closure
    # can MUTATE an outer variable too, not just read it. Classic stateful
    # counter pattern. ---
    var count = 0

    @parameter
    def increment():
        count += 1

    increment()
    increment()
    increment()
    print("count:", count)  # count: 3

    # --- Custom example 2: a practical use — filtering a List with a
    # predicate closure that captures a threshold from the enclosing scope
    # (see filter_list above). Change `threshold` and the same closure code
    # filters differently, with no need to touch filter_list itself. ---
    # Mojo 1.0 changed list-literal inference: `[1, 2, 3]` alone now defaults
    # to Array[Int, N], not List[Int] — the annotation below is required for
    # filter_list's `List[Int]` parameter to accept it.
    var numbers: List[Int] = [1, 5, 8, 2, 9, 3, 12]
    var threshold = 5

    @parameter
    def above_threshold(v: Int) -> Bool:
        return v > threshold

    var big = filter_list[above_threshold](numbers)
    print("above", threshold, end=": ")
    for v in big:
        print(v, end=" ")
    print()  # above 5: 8 9 12

    # --- Current limitation: a capturing closure can't be assigned to a
    # variable / stored as a plain runtime value.
    #   var f = add_n2   # error: TODO: capturing closures cannot be
    #                     # materialized as runtime values
    # It's usable immediately (as above), just not yet a first-class value
    # the way a Python closure is.
