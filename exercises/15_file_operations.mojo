# Tutorial-adjacent: file I/O — open/read/write/close, `with`, and paths.
# Writes/reads/deletes its own scratch file so it leaves nothing behind.
# Run: pixi run mojo run exercises/15_file_operations.mojo

from std.os import remove
from std.os.path import exists
from std.pathlib import Path


def main() raises:
    var path = "mojo_file_demo.txt"

    # --- write (mode "w" creates/truncates) ---
    var f = open(path, "w")
    f.write("hello file")
    f.close()
    print("wrote file")

    # --- read (mode "r") ---
    var g = open(path, "r")
    print(g.read())  # hello file
    g.close()

    # --- `with` — a context manager that closes the file automatically,
    # even if an error occurs inside the block. Prefer this over manual
    # open()/close() pairs. ---
    with open(path, "w") as wf:
        wf.write("line1\nline2\nline3")
    with open(path, "r") as rf:
        var lines = rf.read().split("\n")
        print(lines)  # [line1, line2, line3]

    # --- append (mode "a" adds to the end instead of truncating) ---
    with open(path, "w") as wf:
        wf.write("first")
    with open(path, "a") as wf:
        wf.write(" second")
    with open(path, "r") as rf:
        print(rf.read())  # first second

    # --- checking existence: std.os.path.exists, or Path.exists() ---
    print(exists(path))  # True
    print(exists("definitely_missing_xyz.txt"))  # False
    var p = Path(path)
    print(p.exists())  # True

    # --- opening a missing file raises — handle it like any other error ---
    try:
        var missing = open("definitely_missing_xyz.txt", "r")
    except e:
        print("caught:", e)  # caught: Failed to open file ...: No such ...

    # --- cleanup: remove the scratch file this exercise created ---
    remove(path)
    print("removed:", not exists(path))  # removed: True
