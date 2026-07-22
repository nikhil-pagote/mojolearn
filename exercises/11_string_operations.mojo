# Tutorial-adjacent: common String operations, all verified against this build.
# Run: pixi run mojo run exercises/11_string_operations.mojo


def main():
    var s: String = "  Hello Mojo  "

    # --- case, whitespace ---
    print(s.upper())  # "  HELLO MOJO  "
    print(s.lower())  # "  hello mojo  "
    print("[" + s.strip() + "]")  # [Hello Mojo]

    # --- searching ---
    var t: String = "hello world"
    print(t.find("world"))  # 6  (byte offset, or -1 if not found)
    print("world" in t)  # True — `in` works directly on String
    print(t.startswith("hello"))  # True
    print(t.endswith("world"))  # True

    # --- split / join ---
    var csv: String = "a,b,c"
    var parts = csv.split(",")
    print(parts)  # [a, b, c]
    print(String("-").join(parts))  # a-b-c   (note: join list must be a
    #                                          list literal or List[String]();
    #                                          List[String]("a","b") — the
    #                                          variadic form — does NOT work)

    # --- replace ---
    print(t.replace("world", "Mojo"))  # hello Mojo

    # --- slicing: NOT `s[a:b]` directly — Mojo strings are UTF-8, so you must
    # say whether you mean byte offsets or codepoint (character) offsets. ---
    print(t[byte=0:5])  # hello   — by raw UTF-8 byte position
    print(t[codepoint=6:11])  # world   — by Unicode codepoint position
    # Caveat (this build): codepoint-slicing a string containing multi-byte
    # characters (e.g. accents, emoji) can corrupt the result — verified bug,
    # not shown here. Byte-slicing is reliable for any content.

    # --- length: prefer explicit byte_length()/count_codepoints() over len() ---
    var accented: String = "café"
    print(accented.byte_length())  # 5  (é is 2 bytes in UTF-8)
    print(accented.count_codepoints())  # 4  (4 visible characters)

    # --- building strings from parts ---
    var n = 42
    print("n=" + String(n))  # n=42        — concatenation
    print(String("n=", n))  # n=42        — variadic constructor
    print(s.strip() * 3)  # Hello MojoHello MojoHello Mojo   — repetition

    # --- iterate codepoints ---
    for c in String("abc").codepoints():
        print(c)  # a / b / c
