---
description: Generate a Conventional Commits message from staged changes and commit
agent: build
---

Generate a commit message from the currently staged diff and commit it.

## Staged diff

!`git diff --cached`

## Rules

Follow Conventional Commits: `<type>[optional scope]: <description>`.

- Types: feat, fix, docs, style, refactor, perf, test, build, chore, ci
- Scope (in parentheses) only if relevant
- For breaking changes, add `!` or a `BREAKING CHANGE:` footer
- Description: imperative mood, lower case, no trailing period
- Body explains what and why. Include footers as needed
- Line length <= 74 characters
- Output the commit message only — no commentary, code blocks, or meta statements
- Use English

## Extra context

$ARGUMENTS

If `$ARGUMENTS` contains `-e`, use GitMoji prefix (🐛 fix, ✨ feat, 📝 docs, ♻️ refactor, 🔧 config, etc.) instead of plain type. Treat any remaining text as extra context to incorporate into the message.

## Steps

1. If the diff above is empty, stop and tell the user to stage changes first.
2. Generate a single commit message following the rules above. Incorporate any extra context from `$ARGUMENTS` (ignoring the `-e` flag if present).
3. Commit with DCO sign-off: `git commit -s -m "<message>"`
4. Show the user the generated commit message.
