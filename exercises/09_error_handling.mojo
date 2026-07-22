# Tutorial §8: error handling — raise, try/except/else/finally, re-raise,
# nested handling, and inspecting the caught error.
# Rule: anything that can raise must be in a try/except OR in a `raises` function.
# Run: pixi run mojo run exercises/09_error_handling.mojo


def checked_div(a: Int, b: Int) raises -> Int:
    if b == 0:
        raise Error("division by zero")
    return a // b


def inner() raises:
    raise Error("inner failure")


def outer() raises:
    try:
        inner()
    except:  # bare `except:` — catch-all, no variable
        print("outer: logging then re-raising")
        raise  # bare `raise` re-raises the currently-caught error


def main():
    # --- basic raise / catch, and reading the error message ---
    try:
        print(checked_div(10, 2))  # 5
        print(checked_div(1, 0))  # raises
    except e:
        print("caught:", e)  # caught: division by zero
        print("as String:", String(e))  # extract the message explicitly

    # --- Error(...) accepts multiple args, joined like print()/String() ---
    try:
        raise Error("code=", 404, " not found")
    except e:
        print("caught:", e)  # caught: code=404 not found

    # --- try/except/else: `else` runs only when NO exception occurred.
    # (checked_div is `raises`, so the compiler allows the except branch here
    # even though this particular call succeeds — a bare print() would make
    # `except` provably unreachable and the compiler warns on that.)
    try:
        print(checked_div(10, 5))  # 2 — succeeds, so `else` runs next
    except e:
        print("caught:", e)
    else:
        print("else: no exception occurred")

    # --- finally: always runs, whether or not an exception occurred ---
    try:
        raise Error("boom")
    except e:
        print("caught:", e)
    finally:
        print("finally: cleanup always runs")

    # --- re-raising from a nested handler (see outer()/inner() above) ---
    try:
        outer()
    except e:
        print("main: final catch:", e)  # main: final catch: inner failure

    # --- nested try/except: an inner handler can itself raise a new error,
    # which the outer try/except then catches ---
    try:
        try:
            raise Error("first problem")
        except e:
            print("inner caught:", e)
            raise Error("second problem, raised from the handler")
    except e2:
        print("outer caught:", e2)
