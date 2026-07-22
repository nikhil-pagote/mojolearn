# Mojo Learning Notes

In-repo notes capturing things verified **against this actual environment**
(Mojo 1.0.0b2, pixi build, in the devcontainer) — not copied from online docs,
which often differ from this beta.

> Broader tutorial/quickstart notes live in the Obsidian vault
> (`Developer/Mojo/`). This `docs/` directory is for repo-specific, verified
> findings that should travel with the code.

## Index

- **[Mojo tutorial](mojo-tutorial.md) — start here. A beginner-friendly tour of
  the language, every example verified against this exact compiler.**
- [Toolchain & environment](toolchain-and-environment.md) — how Mojo is
  installed, why it looks Python-heavy, pixi/conda basics.
- [Language notes](language-notes.md) — the `std.` import namespace, `raises`,
  gotchas that differ from online docs.
- [Python interop](python-interop.md) — Mojo ↔ CPython, and the proof that the
  Python dependency is runtime-only and pay-per-use.
- [Troubleshooting](troubleshooting.md) — fixes for errors we've actually hit.
- [Zed setup](zed-setup.md) — installing Mojo language support in Zed (devcontainer).

See also `../PIXI_CHEATSHEET.md` for the pixi command reference.
