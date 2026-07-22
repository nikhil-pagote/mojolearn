# Tutorial §5: collections — List, list literals, Dict, Optional, tuples,
# Set, comprehensions (list/dict/set), and Variant (Mojo's Union equivalent).
# Dict access can raise, so main is `raises`.
# Run: pixi run mojo run exercises/06_collections.mojo

from std.collections import List, Dict, Optional, Set
from std.utils import Variant


def minmax(a: Int, b: Int) -> Tuple[Int, Int]:
    return (a, b) if a < b else (b, a)


def main() raises:
    # List built with append
    var xs = List[Int]()
    xs.append(1)
    xs.append(2)
    xs.append(3)
    print("list len:", len(xs), "first:", xs[0])  # list len: 3 first: 1

    # List literal + iteration
    var ys = [10, 20, 30]
    var s = 0
    for y in ys:
        s += y
    print("sum:", s)  # sum: 60

    # Dict
    var d = Dict[String, Int]()
    d["a"] = 1
    d["b"] = 2
    print("d[a]:", d["a"], "size:", len(d))  # d[a]: 1 size: 2

    # Optional
    var o = Optional[Int](5)
    if o:
        print("optional:", o.value())  # optional: 5

    # Tuple + unpacking (one `var` covers the whole pattern)
    var lo, hi = minmax(9, 4)
    print("min:", lo, "max:", hi)  # min: 4 max: 9

    # Set — unordered, unique elements. `{...}` set-literal syntax also works
    # and really does produce a std.collections.Set (not just a display form).
    var a = Set[Int](1, 2, 3)
    var b: Set[Int] = {2, 3, 4}
    a.add(1)  # duplicate add — no effect, sets stay unique
    print("set size:", len(a))  # set size: 3
    print("union:", a | b)  # union: {1, 2, 3, 4}
    print("intersection:", a & b)  # intersection: {2, 3}

    # Comprehensions — list, dict, and set, all with an optional `if` filter
    var squares = [n * n for n in range(5)]
    print("list comp:", squares)  # list comp: [0, 1, 4, 9, 16]
    var evens = [n for n in range(10) if n % 2 == 0]
    print("filtered:", evens)  # filtered: [0, 2, 4, 6, 8]
    var lookup = {n: n * n for n in range(4)}
    print("dict comp:", lookup)  # dict comp: {0: 0, 1: 1, 2: 4, 3: 9}
    var uniq = {n % 3 for n in range(6)}
    print("set comp:", uniq)  # set comp: {0, 1, 2}

    # Variant — Mojo's Union equivalent (a tagged union of fixed types; there
    # is no `Union` type by that name). .isa[T]() checks which type is active,
    # v[T] extracts it.
    var v: Variant[Int, String] = 42
    if v.isa[Int]():
        print("variant holds Int:", v[Int])  # variant holds Int: 42
    v = String("now a string")
    if v.isa[String]():
        print("variant holds String:", v[String])
