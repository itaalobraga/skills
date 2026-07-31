---
name: create-issue
description: Create a board issue on GitHub (gh or GitHub MCP — same flow) or a temp draft .md when neither is available.
argument-hint: "Project and what the issue covers"
disable-model-invocation: true
---

# Create issue

Collect inputs, draft a brief issue body, then run the same **GitHub branch** via **`gh` or GitHub MCP** — identical steps and verify; only the transport differs (many users have one or the other). If neither can run that branch, write a temporary `.md`; user finishes in the UI.

Probe, GraphQL, CLI commands, MCP: [reference.md](reference.md).

## Collect before drafting

Confirm or infer:

| Input | Required |
| --- | --- |
| Project (`owner` + project number) | yes |
| Title | yes |
| Scope (what to build/fix; what's already done) | yes |
| Assignee | if user names one |
| Issue type | if board repo supports it |
| Client, Product, Env | if project has those fields |
| Started At | default: today (local date, `YYYY-MM-DD`) |
| Example issue URL | if user points at a pattern to mirror |

Investigate the codebase when the issue is about integrating or implementing a feature — the body must describe **this** task only.

Apply [defaults](#defaults-orbe-development-board) when context is obvious; ask when ambiguous.

## Issue body

Follow the org template when one exists (e.g. `orbe-soft/.github` → `.github/ISSUE_TEMPLATE/new-issue.md`). Otherwise use the same four sections:

1. **Descrição** — what and why, 2–4 sentences
2. **Requisitos** — scoped bullets
3. **Critérios de Aceitação** — unchecked checklist
4. **Referências** — only links/files **directly** tied to this task; omit if none

Rules:

- **Brief** — no implementation plans, no endpoint tables, no "fora de escopo" section
- **No cross-task references** — don't cite other issues, specs, or pages unless the user asked or the dependency is explicit
- Keep the Orbe logo header when using the Orbe template

## Delivery channel

After the draft is ready, try **GitHub branch** before [Local branch](#local-branch). Never write a local draft when GitHub branch can complete [Verify (GitHub)](#verify-github).

**Transport** (same workflow either way):

1. If `command -v gh` succeeds → [probe via `gh`](reference.md#probe-via-gh) with collected `owner` and project number. **Pass** → [GitHub branch](#github-branch) using **`gh`**. **Fail** → try step 2 if GitHub MCP is available; else [Local branch](#local-branch) with one line why → [GitHub access](reference.md#github-access).
2. Else if GitHub MCP is in the session → [probe via GitHub MCP](reference.md#probe-via-github-mcp) with the same `owner` and project number. **Pass** → [GitHub branch](#github-branch) using **MCP**. **Fail** → [Local branch](#local-branch); one line why.
3. Else → [Local branch](#local-branch) only.

When `gh` probe fails but MCP is available, run the **MCP probe** before the GitHub branch — do not create an issue on a failed probe.

## GitHub branch

**Transport:** `gh` commands below, or GitHub MCP with the same numbered steps — [reference.md#github-mcp](reference.md#github-mcp).

**Board repo:** `orbe-soft/orbe-development-board` — every GitHub issue in this workflow lives here.

### 1. Create the issue

```bash
gh issue create --repo orbe-soft/orbe-development-board \
  --title "TITLE" \
  --assignee ASSIGNEE \   # omit flag if none
  --body "$(cat <<'EOF'
...body...
EOF
)"
```

Capture the issue number and URL from the output.

### 2. Add to the project

```bash
gh project item-add PROJECT_NUMBER --owner OWNER \
  --url https://github.com/orbe-soft/orbe-development-board/issues/NUMBER
```

### 3. Set board metadata

```bash
gh project field-list PROJECT_NUMBER --owner OWNER --format json
```

For **every new issue**, set **Status** to **`to do`** (never leave default `backlog`).

| Field | Value |
| --- | --- |
| Status | `to do` |
| Client | user-provided or default |
| Product | user-provided or default |
| Env | user-provided or default |
| Started At | today unless user says otherwise |

Use GraphQL `updateProjectV2ItemFieldValue` — [reference.md](reference.md). Match fields **by name**; option IDs differ per project.

### 4. Set issue type

If board repo exposes issue types, set via GraphQL `updateIssue` — [reference.md](reference.md). Skip when board repo has none.

### Verify (GitHub)

Re-read the issue and project item. Confirm:

- [ ] Body follows template; brief; no unrelated references
- [ ] Issue URL is `https://github.com/orbe-soft/orbe-development-board/issues/<number>`
- [ ] Issue is on the project
- [ ] Status is `to do`
- [ ] Client, Product, Env, Started At filled (when those fields exist)
- [ ] Issue type set (when board repo supports it)
- [ ] Return issue URL to the user

## Local branch

Write one file to the OS temporary directory — **not** the workspace (same rule as handoff). Use `$TMPDIR` when set; otherwise `/tmp` on macOS/Linux.

**Filename:** `create-issue-<slug>-<YYYY-MM-DD>.md` — slug from the title (lowercase, hyphens, alphanumeric only, ~40 chars max).

**Contents:**

1. `#` + title
2. Issue body (same markdown as the GitHub branch would use)
3. **`## Board metadata (manual)`** — table or bullets: Project (`owner` + number), assignee, issue type, Status `to do`, Client, Product, Env, Started At (every field you would have set on GitHub)
4. Link: `https://github.com/orbe-soft/orbe-development-board/issues/new`

Return the **absolute path** to the file.

### Verify (local)

- [ ] Body follows template; brief; no unrelated references
- [ ] File exists at the stated absolute path under the temp directory
- [ ] Board metadata section lists every field the GitHub branch would have set
- [ ] User received the path, the new-issue link, and one line on why GitHub branch was skipped (no transport, or access failed on both)

## Defaults (Orbe Development board)

When the user does not override:

| Field | Default |
| --- | --- |
| Status | `to do` |
| Issue type | `Feature` |
| Client / Product | match the product under work (e.g. Grafos) |
| Env | `🌐 web` for frontend work |
| Started At | creation date |
