# Tutorial §1–2: variables and basic types.
# Run: pixi run mojo run exercises/03_variables.mojo


def main():
    var x = 41  # type inferred (Int)
    var y: Int = 1  # explicit type
    x = x + y  # var is reassignable (there is no `let` in this build)
    print("x =", x)  # x = 42

    var f: Float64 = 3.5
    var b: Bool = True
    var s: String = "Mojo"
    print(f, b, s)  # 3.5 True Mojo
    print("double f:", f * 2)  # double f: 7.0
    print("not b:", not b)  # not b: False
    print("greeting:", "hi " + s)  # greeting: hi Mojo
    # len(s) works but warns on String (ambiguous: bytes or codepoints?) —
    # prefer byte_length() or count_codepoints() explicitly.
    print("byte_length:", s.byte_length())  # byte_length: 4
    print(String("x=", x))  # build a string from parts -> x=42
