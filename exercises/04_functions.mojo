# Tutorial §3: functions (def only — there is no `fn` in this build),
# default args, keyword args, and `raises`.
# Run: pixi run mojo run exercises/04_functions.mojo

def add(a: Int, b: Int) -> Int:
    return a + b

def power(base: Int, exp: Int = 2) -> Int:
    var r = 1
    for _ in range(exp):
        r *= base
    return r

def risky(x: Int) raises -> Int:
    if x < 0:
        raise Error("negative")
    return x

def main() raises:
    print("add:", add(2, 3))         # add: 5
    print("power(3):", power(3))     # power(3): 9   (exp defaults to 2)
    print("power(2,5):", power(2, exp=5))  # power(2,5): 32
    print("risky(10):", risky(10))   # risky(10): 10
