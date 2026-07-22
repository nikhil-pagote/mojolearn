# Tutorial §5: collections — List, list literals, Dict, Optional, tuples.
# Dict access can raise, so main is `raises`.
# Run: pixi run mojo run exercises/06_collections.mojo

from std.collections import List, Dict, Optional


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
