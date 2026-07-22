# Tutorial §8: error handling — raise, try/except.
# Rule: anything that can raise must be in a try/except OR in a `raises` function.
# Run: pixi run mojo run exercises/09_error_handling.mojo

def checked_div(a: Int, b: Int) raises -> Int:
    if b == 0:
        raise Error("division by zero")
    return a // b


def main():
    try:
        print(checked_div(10, 2))   # 5
        print(checked_div(1, 0))    # raises
    except e:
        print("caught:", e)         # caught: division by zero
