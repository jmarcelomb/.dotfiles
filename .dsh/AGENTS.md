# Global agent instructions

These instructions apply to every DSH session on this machine (web and TUI),
on top of any project-level AGENTS.md.

## Memory

Before the first memory read or write in a session, bind the session's
project: call `mcp__memorix__memorix_session_start` with `projectRoot` set to
your current working directory (a git repo, or any folder — non-git folders
fall back to the `untracked/` project). Then:

- When the user asks you to remember something, store it with
  `mcp__memorix__memorix_store`.
- When historical information may be relevant, search with
  `mcp__memorix__memorix_search` and use relevant results.
- Prefer memory over asking the user again for facts you were already told.

## Context7 docs

Use the Context7 MCP (`mcp__context7__*`) to fetch current documentation
whenever the user asks about a library, framework, SDK, API, CLI tool, or
cloud service — even well-known ones (React, Next.js, Prisma, Express,
Tailwind, ...). This includes API syntax, configuration, version migration,
library-specific debugging, setup instructions, and CLI usage. Use it even
when you think you know the answer — training data may be out of date.
Prefer it over web search for library docs.

Do not use it for: refactoring, writing scripts from scratch, debugging
business logic, code review, or general programming concepts.

Steps:

1. Start with `mcp__context7__resolve-library-id` using the library name and
   the user's question, unless the user gives an exact library ID
   (`/org/project` format).
2. Pick the best match by: exact name, description relevance, snippet count,
   source reputation, benchmark score. If results look wrong, try alternate
   names or rephrase.
3. Call `mcp__context7__query-docs` with the selected library ID and the
   user's full question (not single words).
4. If the answer is not good enough, call `mcp__context7__query-docs` again
   with `researchMode: true` (costlier: sandboxed agents + live search).
5. Answer using the fetched docs.
