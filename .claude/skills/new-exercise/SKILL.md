---
name: new-exercise
description: Scaffold and verify a new numbered Mojo exercise under exercises/. Use when the user wants to add a new exercise, practice file, or example .mojo script for a topic (e.g. "add an exercise for closures", "new exercise on error handling").
---

# new-exercise

Create the next runnable exercise in `exercises/`, correct for this build
(Mojo 1.0.0b2), and verify it actually runs before finishing.

## Steps

1. **Pick the number.** Exercise numbers follow a pedagogical learning-curve
   order (fundamentals → data/collections → error handling → structs/OOP
   substitutes → advanced/specialized), NOT just "append to the end" — check
   `docs/mojo-tutorial.md`'s exercises table to see where the new topic
   actually belongs, and be prepared to renumber existing files (via `git mv`
   through temporary names to avoid collisions) if inserting in the middle.
   Derive a short snake_case name from the topic: `NN_<topic>.mojo`.

2. **Write the file** using ONLY this build's verified syntax (see
   `.claude/agents/mojo-expert.md` and `docs/language-notes.md`):
   - `def` only (no `fn`), `var` only (no `let`).
   - `@fieldwise_init` for structs with a fieldwise constructor.
   - Stdlib under `std.` (`from std.collections import List`, etc.).
   - `def main() raises:` if it calls anything fallible (Dict, Python, raise).
   Start with a comment header: what the exercise shows + the run command.
   Keep it focused and print results so running it is a visible check.

3. **Verify it runs** (do not skip):
   ```bash
   pixi run mojo run exercises/NN_<topic>.mojo
   ```
   For Python interop, prefix with
   `MOJO_PYTHON_LIBRARY=$(find .pixi/envs/default/lib -maxdepth 1 -name 'libpython3*.so' | head -1)`.
   Fix any error and re-run until it passes cleanly.

4. **Link it (optional).** If it maps to a tutorial section, add a row to the
   exercises table in `docs/mojo-tutorial.md`.

5. **Report** the file path, what it demonstrates, and the actual output.
