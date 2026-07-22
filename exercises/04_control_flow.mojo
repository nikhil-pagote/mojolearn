# Tutorial §4: control flow — if/elif/else, ternary, while, for/range.
# Run: pixi run mojo run exercises/04_control_flow.mojo

def grade(n: Int) -> String:
    if n >= 90:
        return "A"
    elif n >= 80:
        return "B"
    else:
        return "C"

def main():
    print(grade(95), grade(85), grade(50))   # A B C

    var x = 5
    print("big" if x > 3 else "small")       # big

    var i = 0
    while i < 3:
        i += 1

    var total = 0
    for k in range(5):        # 0,1,2,3,4
        total += k

    print("i =", i, "total =", total)        # i = 3 total = 10
