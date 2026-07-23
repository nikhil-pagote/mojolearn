---
title: Mojo language support in Zed
description: Setting up the unofficial community Mojo extension for Zed against this devcontainer.
status: reference
tags: [zed, ide-setup]
updated: 2026-07-22
---

# Mojo language support in Zed (devcontainer)

We use Zed with this project as a **devcontainer** (Zed runs on the host, the
code + language servers run in the container). There is **no official Mojo
extension** for Zed, so we use the community extension
[`bajrangCoder/zed-mojo`](https://github.com/bajrangCoder/zed-mojo) as a *dev
extension*. It gives syntax highlighting, outline, and LSP features
(hover, diagnostics, go-to-definition) by launching the Mojo language server
that already ships in our pixi env.

## What's already prepared (done in-container)

- ✅ Extension source cloned to **`tools/zed-mojo/`** (git-ignored; reachable
  from both host and container because the workspace is a bind mount).
- ✅ Verified the exact command the extension runs — `pixi run mojo-lsp-server`
  — launches the Mojo LSP successfully from the project root.
- ✅ `pixi` is on `PATH`, which is how the extension locates the server.

So no LSP path configuration is needed — the extension finds `pixi` and runs the
server through it automatically.

## Install it (host-side, in the Zed UI)

This is the one step that must happen in the Zed app (it can't be done from
inside the container):

1. Open this project in Zed (connected to the devcontainer).
2. Open the Extensions view — command palette (`Cmd/Ctrl-Shift-P`) →
   **`zed: extensions`**.
3. Click **"Install Dev Extension"**.
4. In the folder picker, choose **`tools/zed-mojo`** in this project.
5. Zed compiles the extension (this fetches the `tree-sitter-mojo` grammar and
   the Zed extension API — needs network the first time).
6. Open any `.mojo` file — you should get highlighting, and the LSP starts via
   `pixi run mojo-lsp-server`.

Check the language server is alive: command palette → **`zed: open language
server logs`** → look for the Mojo server.

## Notes & caveats

- **Formatter:** `mojo format` (Black-based `mblack`) **works** and is wired up
  in `.zed/settings.json` as an external formatter (`pixi run mojo format -q -`)
  with format-on-save. Note: it only works because we fixed a stale-shebang bug
  in `mblack` — see [troubleshooting.md](troubleshooting.md) if it ever silently
  stops formatting.
- **Build failures:** dev-extension installs can hit Wasm-ABI / tree-sitter
  grammar compile errors depending on the Zed version. If that happens, update
  Zed to the latest, or try the alternatives
  [`adityasz/zed-mojo`](https://github.com/adityasz/zed-mojo) or
  [`freespirit/mz`](https://github.com/freespirit/mz).
- **Unofficial:** when Modular ships an official Zed extension, uninstall this
  dev extension and install the official one from the registry.

## Updating the extension

```bash
cd tools/zed-mojo && git pull
```

Then in Zed: Extensions → the Mojo dev extension → **Rebuild**.
