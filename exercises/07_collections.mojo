# Tutorial §5: every collection type in std.collections — List, list
# literals, Dict, Optional, tuples, Set, Deque, Counter, InlineArray,
# LinkedList, BitSet — plus Variant (Mojo's Union equivalent).
# Comprehensions have their own file: exercises/08_comprehensions.mojo.
# Dict/Deque access can raise, so main is `raises`.
# Run: pixi run mojo run exercises/07_collections.mojo

from std.collections import (
    List,
    Dict,
    Optional,
    Set,
    Deque,
    Counter,
    InlineArray,
    LinkedList,
    BitSet,
)
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

    # Deque — double-ended queue: append/appendleft, pop/popleft.
    var dq = Deque[Int]()
    dq.append(1)
    dq.append(2)
    dq.appendleft(0)
    print("deque:", dq)  # deque: [0, 1, 2]
    print("popleft:", dq.popleft())  # popleft: 0
    print("pop:", dq.pop())  # pop: 2

    # Counter — Dict-like, counts occurrences (defaults missing keys to 0).
    var counts = Counter[String]()
    counts["a"] += 1
    counts["a"] += 1
    counts["b"] += 1
    print("counts:", counts["a"], counts["b"])  # counts: 2 1

    # InlineArray — fixed-size, stack-allocated array. Needs `fill=` (a
    # variadic constructor like List's does NOT work here) or
    # `uninitialized=True` if you're about to overwrite every slot anyway.
    var arr = InlineArray[Int, 3](fill=0)
    arr[0] = 1
    arr[1] = 2
    arr[2] = 3
    print("inline array:", arr[0], arr[1], arr[2], "len:", len(arr))

    # LinkedList
    var ll = LinkedList[Int]()
    ll.append(1)
    ll.append(2)
    ll.append(3)
    print("linked list:", ll, "len:", len(ll))

    # BitSet — a fixed-capacity set of bit flags.
    var bs = BitSet[64]()
    bs.set(3)
    bs.set(5)
    print("bitset test(3):", bs.test(3), "test(4):", bs.test(4))

    # Variant — Mojo's Union equivalent (a tagged union of fixed types; there
    # is no `Union` type by that name). .isa[T]() checks which type is active,
    # v[T] extracts it.
    var v: Variant[Int, String] = 42
    if v.isa[Int]():
        print("variant holds Int:", v[Int])  # variant holds Int: 42
    v = String("now a string")
    if v.isa[String]():
        print("variant holds String:", v[String])
