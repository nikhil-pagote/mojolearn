# Tutorial §9: SIMD — a taste of why Mojo is fast. One SIMD value holds several
# numbers and math applies to all lanes at once.
# Run: pixi run mojo run exercises/16_simd.mojo

def main():
    var v = SIMD[DType.int32, 4](1, 2, 3, 4)
    print("v      =", v)            # v      = [1, 2, 3, 4]
    print("v * 2  =", v * 2)        # v * 2  = [2, 4, 6, 8]
    print("v + v  =", v + v)        # v + v  = [2, 4, 6, 8]

    # Float lanes work too.
    var f = SIMD[DType.float64, 2](1.5, 2.5)
    print("f * 2  =", f * 2)        # f * 2  = [3.0, 5.0]
