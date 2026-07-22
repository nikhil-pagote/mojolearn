# Tutorial §1-2: variables and all supported scalar data types.
# Run: pixi run mojo run exercises/02_variables.mojo


def main():
    # --- variables ---
    var x = 41  # type inferred (Int)
    var y: Int = 1  # explicit type
    x = x + y  # var is reassignable (there is no `let` in this build)
    print("x =", x)  # x = 42

    # --- signed integers: Int (machine word) + fixed-width variants ---
    var i: Int = -42
    var i8: Int8 = -42
    var i16: Int16 = -42
    var i32: Int32 = -42
    var i64: Int64 = -42
    var i128: Int128 = -42
    var i256: Int256 = -42
    print("signed:", i, i8, i16, i32, i64, i128, i256)

    # --- unsigned integers: UInt (machine word) + fixed-width variants ---
    var u: UInt = 42
    var u8: UInt8 = 42
    var u16: UInt16 = 42
    var u32: UInt32 = 42
    var u64: UInt64 = 42
    var u128: UInt128 = 42
    var u256: UInt256 = 42
    print("unsigned:", u, u8, u16, u32, u64, u128, u256)
    # `Byte` is an alias for UInt8 — used for raw byte data.
    var raw: Byte = 65
    print("Byte (alias of UInt8):", raw)

    # --- floating point ---
    var f16: Float16 = 3.5
    var f32: Float32 = 3.5
    var f64: Float64 = 3.5  # default float type for bare literals like `3.5`
    var bf16: BFloat16 = 3.5  # bfloat16 — wider exponent, less precision
    var f8: Float8_e4m3fn = 1.5  # 8-bit float (ML use cases)
    print("float:", f16, f32, f64, bf16, f8)
    print("double f64:", f64 * 2)  # double f64: 7.0

    # --- bool ---
    var b: Bool = True
    print("not b:", not b)  # not b: False

    # --- string ---
    var s: String = "Mojo"
    print("greeting:", "hi " + s)  # greeting: hi Mojo
    # len(s) works but warns on String (ambiguous: bytes or codepoints?) —
    # prefer byte_length() or count_codepoints() explicitly.
    print("byte_length:", s.byte_length())  # byte_length: 4
    print(String("x=", x))  # build a string from parts -> x=42
