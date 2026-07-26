# List, dict, and set comprehensions — all build eagerly (there are no
# generators in this build: neither `(x for x in ...)` generator expressions
# nor `yield` generator functions parse — see docs/mojo-training-slides.html
# Session 3).
# Run: pixi run mojo run exercises/08_comprehensions.mojo


def main():
    # --- list comprehension ---
    var squares = [n * n for n in range(5)]
    print("list comp:", squares)  # list comp: [0, 1, 4, 9, 16]

    # --- list comprehension with an `if` filter ---
    var evens = [n for n in range(10) if n % 2 == 0]
    print("filtered:", evens)  # filtered: [0, 2, 4, 6, 8]

    # --- dict comprehension ---
    var lookup = {n: n * n for n in range(4)}
    print("dict comp:", lookup)  # dict comp: {0: 0, 1: 1, 2: 4, 3: 9}

    # --- dict comprehension with an `if` filter ---
    var odd_lookup = {n: n * n for n in range(6) if n % 2 == 1}
    print("dict filtered:", odd_lookup)  # dict filtered: {1: 1, 3: 9, 5: 25}

    # --- set comprehension (deduplicates automatically) ---
    var uniq = {n % 3 for n in range(6)}
    print("set comp:", uniq)  # set comp: {0, 1, 2}

    # --- comprehension over an existing collection, not just range() ---
    var words = ["hi", "mojo", "world"]
    var lengths = [w.byte_length() for w in words]
    print("lengths:", lengths)  # lengths: [2, 4, 5]
