---
name: SecurityBestPractices
description: "Language and framework specific security reviews for python, javascript/typescript, and go. USE WHEN the user requests a security review, secure-by-default coding help, or a vulnerability report. Not for general code review or debugging."
version: 0.1.0
allowed-tools: Read, Grep, Glob, Write
upstream: https://github.com/davila7/claude-code-templates/blob/main/cli-tool/components/skills/security/security-best-practices/SKILL.md
---

# SecurityBestPractices

Language and framework specific security best practices — secure-by-default coding, passive detection, or a full vulnerability report.

## Scope

Triggers only for python, javascript/typescript, and go. For other languages, rely on general knowledge and flag that concrete guidance is not available.

## Workflow

1. **Identify** the languages and frameworks in use — frontend and backend separately for web apps. Focus on the primary core frameworks.
2. **Load guidance** — if this skill's `references/` directory contains `<language>-<framework>-<stack>-security.md` or a general `<language>-general-<stack>-security.md`, read all matching files. Web apps need both frontend and backend references.
3. **Operate in one of three modes**:

| Mode                    | Trigger                                     | Behavior                                                          |
| ----------------------- | ------------------------------------------- | ----------------------------------------------------------------- |
| Write secure-by-default | Starting new project or writing new code    | Apply guidance proactively                                        |
| Passively detect        | Working in an existing project              | Flag critical findings to the user inline                         |
| Full report             | User explicitly requests it                 | Write `security_best_practices_report.md` with prioritized issues |

If no references exist for the stack, note that concrete guidance is unavailable but still perform the action based on general security knowledge.

## Overrides

Project-level documentation may require bypassing specific best practices. When overriding, report the override to the user without arguing. Suggest adding a note to project docs explaining the reason so the bypass is visible to future work.

## Report Format

- Write to `security_best_practices_report.md` unless the user specifies another path
- Short executive summary at top
- Delineated sections by severity; focus on critical findings
- Number findings with a numeric ID for cross-reference
- For critical findings, include a one-sentence impact statement
- When referencing code, include file paths and line numbers
- After writing the file, summarize findings and point to the report location

## Fixes

Apply fixes one finding at a time. Add concise comments in the code pointing to the specific best practice. Consider regressions — insecure code often survives because it's load-bearing; break things and the user will reject future fixes.

Follow the project's commit and testing conventions. Commit messages should reference the security best practice being aligned to. Avoid bundling unrelated findings.

## General Advice

### Avoid incrementing IDs for publicly exposed resources

Use UUID4 or random hex strings instead of small auto-incrementing integers. Prevents enumeration attacks and resource-count inference.

### TLS and secure cookies

Do not report missing TLS as a security issue — dev environments rarely have TLS or use an out-of-scope proxy. Set `Secure` on cookies only when the app is actually over TLS; otherwise local dev and testing break. Provide an env flag to gate `Secure`. Avoid recommending HSTS — its lasting impact (including major user lockouts) requires deep understanding.

## Constraints

- Trigger only on explicit security-review requests, never on generic code review or debugging
- Do not argue with project-level overrides; document them instead
- Report dev-only TLS gaps as best-practice notes, not vulnerabilities
