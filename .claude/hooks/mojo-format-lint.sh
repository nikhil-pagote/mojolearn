#!/usr/bin/env bash
# PostToolUse hook: after a .mojo file is edited, auto-FORMAT then LINT it.
#
#   format : `mojo format` in place (Black-based mblack; also a syntax check)
#   lint   : exercises/*.mojo -> `mojo run` (build + execute + warnings)
#            any other .mojo   -> `mojo doc`  (type-check; works with no main())
#
# Errors and warnings are fed back to Claude via exit code 2. jq isn't installed
# in this env, so file_path is parsed from the hook JSON with grep/sed.
set -u

input=$(cat)
file=$(printf '%s' "$input" \
  | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/')

case "$file" in
  *.mojo) ;;
  *) exit 0 ;;                       # not a Mojo file — nothing to do
esac

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
[ -f "$file" ] || exit 0

# 1) Format in place. A failure here is a real parse/syntax error — surface it.
fmt=$(pixi run mojo format -q "$file" 2>&1)
if [ $? -ne 0 ]; then
  { echo "⚠️  mojo format failed for $file (syntax error?):"
    printf '%s\n' "$fmt" | grep -m5 -iE 'error|cannot parse' | sed 's/^/    /'; } >&2
  exit 2
fi

# 2) Lint / type-check.
case "$file" in
  */exercises/*.mojo|exercises/*.mojo)
    out=$(pixi run mojo run "$file" 2>&1); rc=$?
    ;;
  *)
    out=$(pixi run mojo doc "$file" -o /dev/null 2>&1); rc=$?
    ;;
esac

if [ "$rc" -ne 0 ]; then
  { echo "⚠️  mojo lint failed for $file:"
    printf '%s\n' "$out" | grep -m6 -iE 'error:|ABORT' | sed 's/^/    /'; } >&2
  exit 2
fi

warns=$(printf '%s\n' "$out" | grep -iE 'warning:')
if [ -n "$warns" ]; then
  { echo "ℹ️  mojo warnings for $file:"
    printf '%s\n' "$warns" | head -5 | sed 's/^/    /'; } >&2
  exit 2
fi
exit 0
