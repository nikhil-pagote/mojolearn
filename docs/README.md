---
title: Mojo Learning Notes
description: Index of in-repo Mojo learning material — the training deck plus environment/IDE notes.
status: reference
tags: [index, docs]
updated: 2026-08-13
---

# Mojo Learning Notes

## Index

- **[Mojo — Training Deck](mojo-training-slides.html) — start here.** A
  6-session slide deck covering the whole language. Sessions 1–5 are
  compiler-verified against this exact environment (Mojo 1.0.0, pixi,
  in the devcontainer) — written against 1.0.0b2 originally, with
  "changed in 1.0.0" callouts added where stable diverged; Session 6 covers
  documentation, compile-time
  parameters, memory & pointers, metaprogramming, advanced functions,
  modules & packages, and interop with C, MLIR, and the GPU. Open it
  directly in a browser, or publish it as a Claude Artifact.
- [Troubleshooting](troubleshooting.md) — fixes for errors we've actually hit
  in this devcontainer (stale paths, crash-log lock files, env rebuilds).
- [Zed setup](zed-setup.md) — installing Mojo language support in Zed
  (devcontainer).

See also `../PIXI_CHEATSHEET.md` for the pixi command reference, and
[nikhilpagote.uk/tutorials/mojo](https://nikhilpagote.uk/tutorials/mojo) for a
companion tutorial site.

> Broader tutorial/quickstart notes also live in the Obsidian vault
> (`Developer/Mojo/`). This `docs/` directory is for repo-specific, verified
> findings that should travel with the code.

## Exercises index

One runnable script per topic under `exercises/` — run any of them with
`pixi run mojo run exercises/<file>`. Numbered in learning-curve order:
fundamentals → working with data → robustness → custom types/OOP substitutes →
advanced/specialized. Matches the training deck's Sessions 1–5.

| File | Covers |
|---|---|
| `01_hello.mojo` | Hello world |
| `02_variables.mojo` | Variables & all supported scalar types |
| `03_operators.mojo` | Arithmetic/comparison/logical/bitwise operators, short-circuit, `in`/`is`, `Int/Int` truncation gotcha, operator overloading (`__add__`, `__eq__`, `Writable`), copy vs `^` transfer |
| `04_control_flow.mojo` | if/elif/else, ternary, loops |
| `05_functions.mojo` | Functions, defaults, `raises` |
| `06_string_operations.mojo` | String methods: case, strip, split/join, replace, find, slicing (`byte=`/`codepoint=`), length, `t"..."` interpolation |
| `07_collections.mojo` | List, Dict, Optional, tuples, Set, Deque, Counter, InlineArray, LinkedList, BitSet, Variant |
| `08_comprehensions.mojo` | List/dict/set comprehensions, `if` filters, no generators |
| `09_error_handling.mojo` | raise / try / except / else / finally / re-raise |
| `10_structs.mojo` | Structs, methods, `mut self` |
| `11_struct_constructors.mojo` | `__init__` overloading, defaults, `@staticmethod` factories, `@fieldwise_init` |
| `12_no_inheritance.mojo` | No classes, no struct inheritance — composition + traits instead |
| `13_traits_generics.mojo` | Traits & generics, trait composition |
| `14_closures.mojo` | Capturing via `capturing` keyword or `@parameter`; closures as compile-time args. (1.0.0 added a `lambda` keyword usable as a runtime value — not yet covered here; `capturing`/`@parameter` closures still can't be.) |
| `15_file_operations.mojo` | File I/O: open/read/write/close, `with`, append mode, existence checks, error handling |
| `16_simd.mojo` | SIMD |
| `17_python_interop.mojo` | Calling Python |

When you build reusable structs/traits from these exercises, move them into
`src/mojolearn/`.
