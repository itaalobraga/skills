---
name: create-issue
description: Create a GitHub issue on the board (or a local draft .md when gh lacks permission).
argument-hint: "Project and what the issue covers"
disable-model-invocation: true
---

# Create issue

Collect inputs, draft a brief issue body, then **probe** `gh` access. **Pass** → create on GitHub, wire project + metadata, verify. **Fail** → write a temporary `.md` only; user finishes in the UI.

GraphQL and probe commands: [reference.md](reference.md).

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

## Probe (binary)

After the draft is ready, run the **binary probe** in [reference.md](reference.md) with the collected `owner` and project number.

- **Pass** → [GitHub branch](#github-branch) only. Do not write a local draft file.
- **Fail** → [Local branch](#local-branch) only. Do not run `gh issue create`, `project item-add`, or field mutations. Tell the user **one line** why the probe failed and point to [reference.md — gh access](reference.md#gh-access).

## GitHub branch

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
- [ ] User received the path, the new-issue link, and one line on why `gh` was skipped (if probe failed)

## Defaults (Orbe Development board)

When the user does not override:

| Field | Default |
| --- | --- |
| Status | `to do` |
| Issue type | `Feature` |
| Client / Product | match the product under work (e.g. Grafos) |
| Env | `🌐 web` for frontend work |
| Started At | creation date |
