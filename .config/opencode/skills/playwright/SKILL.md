---
name: playwright
description: Using the Playwright MCP browser tools in Code Mode. Use when taking screenshots, navigating pages, or doing any browser automation — prevents the recurring search() and tool-call failures.
---

# Playwright in Code Mode

Playwright tools do not exist as direct tool calls. They run only inside the
`execute` tool, as JavaScript. Get this wrong and you burn turns on
`Tool 'search' expects at most one input object` or `SchemaError(Expected object)`.

## The correct pattern

```js
// 1. search takes exactly ONE object argument with a query string
const found = search({ query: "screenshot" });
// 2. call tools by their EXACT path and signature from the search results
await tools.playwright["browser_navigate"]({ url: "http://localhost:5173" });
await tools.playwright["browser_take_screenshot"]({ filename: "shot.png" });
return "done";
```

## Rules

1. **Search first, every session.** Call `search({ query: "..." })` before the
   first browser call. Do not guess tool names; use exactly what search returns.
2. **One argument, one object.** Every tool call takes a single object.
   `search("screenshot")` and `search({query: "screenshot"}, something)` both fail.
3. **Await everything.** Browser calls are async; a dropped await means you act
   on a page that has not loaded.
4. **Dotted and bracket paths both work** — `tools.playwright.browser_navigate`
   equals `tools.playwright["browser_navigate"]`. Use bracket notation when the
   name has characters a dotted path cannot carry.
5. **Return a value** so the result is visible.

## Screenshot workflow

```js
await tools.playwright["browser_navigate"]({ url });
// wait for render: network idle equivalent. Prefer waiting for real content
// over a blind time sleep on dynamic apps (JS must execute before you inspect).
await tools.playwright["browser_wait_for"]({ text: "<known content>" });
```

Reconnaissance-then-action: inspect before you act.

```js
const dom = await tools.playwright["browser_snapshot"](); // accessibility tree
```

Use `browser_snapshot` (DOM structure) to find selectors, `browser_console_messages`
to check for JS errors, and `browser_take_screenshot` only for what the DOM
cannot tell you. Do not screenshot before the page has rendered.

Then analyze the screenshot file. One image per call:

- Prefer the `vision-glm-flash` subagent (isolated child session) or the
  `vision-proxy` MCP `describe_image` tool.
- The self-hosted model gateway rejects any prompt with more than one image.
  Never read two images into the same session context; invoke the subagent once
  per screenshot.

## Heavier test flows: skip MCP, write a script

For multi-step test automation (many actions, assertions, repeated runs), round
trips through `execute` cost more than they save. Write a native Python
Playwright script instead:

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)  # always headless for scripts
    page = browser.new_page()
    page.goto("http://localhost:5173")
    page.wait_for_load_state("networkidle")  # critical before inspecting dynamic apps
    page.screenshot(path="shot.png", full_page=True)
    browser.close()
```

This matches Anthropic's `webapp-testing` skill pattern
(github.com/anthropics/skills, skills/webapp-testing): wait for `networkidle`
before any inspection, use descriptive selectors (`text=`, `role=`, CSS), close
the browser when done.

## Cert errors (ERR_CERT_AUTHORITY_INVALID)

Local dev servers on https with self-signed certs fail in Playwright. Do not
fight the cert. Use the http URL instead (`http://localhost:<port>`), or start
the dev server in http mode. If the page must be https, ask the user before
disabling verification.
