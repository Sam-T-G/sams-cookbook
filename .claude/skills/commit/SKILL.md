---
description: Create a well-formed commit for the staged work, with a short Title Case noun-phrase subject and no AI trace.
user-invocable: true
disable-model-invocation: true
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*)
argument-hint: "[a short subject, or let the skill propose one]"
---

# /commit

Create one focused commit. Side-effecting, so this skill is never auto-invoked.

## Steps

1. `git status` and `git diff` to see what is staged. If nothing is staged, stage the intended files.
2. Confirm `swift test` is green first (the Stop hook will block otherwise).
3. Write a subject in the house style: Title Case, a noun phrase, two to six words, no body, no scope
   prefix. Examples: "Concurrency posture recipe", "Typed networking client", "Format output".
4. Do not add any AI attribution: no `Co-Authored-By`, no "Generated with", no emoji trailer. The trace
   convention for commits in this repo is zero trace, even though the `.claude/` directory itself ships.
5. Commit. Report the short hash.

## Notes

- One logical change per commit. If the diff spans two ideas, split it.
- Never commit `Secrets.xcconfig` or any `.dev.vars` file (the pre-commit hook also blocks this).
