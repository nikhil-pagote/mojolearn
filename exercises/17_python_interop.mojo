# Python interop: Mojo calling into CPython.
#
# Notes for this build (Mojo 1.0.0b2, pixi):
#   * The stdlib is namespaced under `std.` here, so it's `from std.python ...`
#     (not the `from python ...` you'll see in most online docs/tutorials).
#   * Python.import_module can raise, so main must be `raises`.
#
# Run it (CPython must be discoverable at runtime — see below):
#   LIBPY=$(find .pixi/envs/default/lib -maxdepth 1 -name 'libpython3*.so' | head -1)
#   MOJO_PYTHON_LIBRARY="$LIBPY" pixi run mojo run exercises/17_python_interop.mojo
#
# Why the env var? Mojo does NOT link libpython at build time. It dlopen()s a
# CPython runtime *on demand*, only because this program uses Python interop.
# Compare exercises/01_hello.mojo, which never touches Python and runs with no
# libpython at all. That's the point: the Python dependency is pay-per-use.

from std.python import Python


def main() raises:
    var math = Python.import_module("math")
    var result = math.sqrt(2.0)
    print("Python math.sqrt(2.0) =", result)
