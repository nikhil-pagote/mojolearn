---
name: commit-push
description: Stage, commit, and push all pending changes to origin/main. User-triggered only — run when the user explicitly invokes this skill (e.g. "/commit-push", "commit and push"), never automatically after routine edits.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash(git status *), Bash(git diff *), Bash(git log *), Bash(git add *), Bash(git commit *), Bash(git push *)
---

# commit-push

This repo intentionally does NOT commit/push after every small edit — the
user batches changes and runs this skill themselves when ready. Only run
this flow when the user explicitly invokes it.

## Steps

1. Run in parallel: `git status` (never `-uall`), `git diff` (staged +
   unstaged), and `git log --oneline -5` (to match this repo's message
   style — short, why-focused, e.g. "Document ^ (transfer operator)
   semantics — compile-time move, not runtime delete").

2. Review the diff. Do not stage anything that looks like a secret/credential
   file. If nothing has changed, say so and stop — don't create an empty
   commit.

3. Draft a concise (1-2 sentence) commit message focused on *why*, matching
   the tone of recent commits (see `git log` output). If the pending changes
   cover multiple unrelated topics, consider whether they should be split
   into separate commits — ask the user if unsure.

4. Stage the relevant files by name (not `git add -A`/`.`), commit with:
   ```
   git commit -m "$(cat <<'EOF'
   <message>

   Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
   EOF
   )"
   ```

5. Push: `git push origin main`.

6. Report the commit hash(es) and confirm the push succeeded (`git log
   --oneline -3` after pushing).
