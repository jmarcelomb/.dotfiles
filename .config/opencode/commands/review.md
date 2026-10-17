---
description: Deep review of current changes with all reviewers in parallel. Report-only.
agent: review-coordinator
---

Review the current changes. This command is report-only: it does not modify any files. The user decides what to fix after reading the findings.

## Scope

$ARGUMENTS

If `$ARGUMENTS` is empty, review the current uncommitted changes: `git diff HEAD` covers staged and unstaged changes to tracked files. If that is empty and the user did not name a scope, say so and stop. Do not fall back to reviewing past commits unless the user asks.

If the user passed a file path, directory, or commit range, use that as the scope instead.

## Delegation

Delegate the review to `review-coordinator` with the change scope and review depth set to "deep" (run all reviewers). The coordinator will:

1. Run `quick-review-glm-5.3-flash` first for a fast first-pass.
2. Spawn the full deep reviewer batch in parallel: `review-correctness-glm-5.2`, `review-integration-glm-5.3-flash`, `review-performance-glm-5.2`, `review-challenger-qwen3-coder-480b`, `review-challenger-gpt-5.6-terra`, `review-deep-glm-5.3-flash`, `security-reviewer-qwen3-coder-480b`, `test-review-glm-5.2`.
3. Collect and deduplicate findings, grouped by severity.
4. Return a consolidated report.

## Final quality pass

After the coordinator returns, spawn `quality-pass-glm-5.2` as a background subagent. Give it the full diff (`git diff HEAD`) and this instruction:

1. Review the complete change with fresh eyes.
2. Look for remaining bugs, edge cases, error handling gaps, naming issues, missing tests, and quality-of-life improvements.
3. Report each finding with the failure condition, file and line references, and evidence. Separate defects from optional improvements.

When it finishes, add its findings to the coordinator's report. Deduplicate against existing findings.

## Reconciliation

When all findings are in, verify disputed findings against the code, then reconcile into a single list:

- Deduplicate overlapping findings and note which reviewers agreed.
- Group by severity: critical, high, medium, low, nitpick.
- One line per finding: file path, line number, what's wrong, suggested fix.
- If a reviewer found nothing, say so. Do not invent findings.
- Include the quick first pass findings if they were not caught by the deep reviewers.
- End with a verdict: issues per severity and whether the changes are ready to merge.

## Output

Present the complete findings report to the user:

1. Summary table: severity, count, and which reviewers contributed.
2. Findings grouped by severity (critical first), each with file path, line number, description, and suggested fix.
3. Verdict: whether the changes are ready to merge, and what should be fixed before merging.

Do not modify any files. Do not apply fixes. Let the user decide what to act on.
