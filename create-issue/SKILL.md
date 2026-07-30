---
name: create-issue
description: Create a GitHub issue, add it to a Project board, and fill board metadata.
argument-hint: "Repo, project, and what the issue covers"
disable-model-invocation: true
---

# Create issue

End-to-end workflow: draft a brief issue body, create it on GitHub, add it to a Project, set **board metadata**, verify.

Use `gh` for GitHub operations. Field IDs and GraphQL snippets: [reference.md](reference.md).

## Collect before drafting

Confirm or infer:

| Input | Required |
| --- | --- |
| Repository (`owner/repo`) | yes |
| Project (`owner` + project number) | yes |
| Title | yes |
| Scope (what to build/fix; what's already done) | yes |
| Assignee | if user names one |
| Issue type | if repo supports it |
| Client, Product, Env | if project has those fields |
| Started At | default: today (local date, `YYYY-MM-DD`) |
| Example issue URL | if user points at a pattern to mirror |

Investigate the codebase when the issue is about integrating or implementing a feature — the body must describe **this** task only.

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

Pass the body via heredoc to `gh issue create`.

## Create and wire up

### 1. Create the issue

```bash
gh issue create --repo OWNER/REPO \
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
  --url https://github.com/OWNER/REPO/issues/NUMBER
```

### 3. Set board metadata

List fields first:

```bash
gh project field-list PROJECT_NUMBER --owner OWNER --format json
```

For **every new issue**, set **Status** to **`to do`** (never leave default `backlog`).

Set other fields the project defines and the user supplied:

| Field | Value |
| --- | --- |
| Status | `to do` |
| Client | user-provided |
| Product | user-provided |
| Env | user-provided |
| Started At | today unless user says otherwise |

Use GraphQL `updateProjectV2ItemFieldValue` — see [reference.md](reference.md). Match fields **by name**; option IDs differ per project.

### 4. Set issue type

If the repo exposes issue types, set via GraphQL `updateIssue` — see [reference.md](reference.md). Skip when the repo has no issue types.

## Verify

Re-read the issue and project item. Confirm:

- [ ] Body follows template; brief; no unrelated references
- [ ] Issue is on the project
- [ ] Status is `to do`
- [ ] Client, Product, Env, Started At filled (when those fields exist)
- [ ] Issue type set (when repo supports it)
- [ ] Return issue URL to the user

## Defaults (Orbe Development board)

When the user does not override:

| Field | Default |
| --- | --- |
| Status | `to do` |
| Issue type | `Feature` |
| Client / Product | match the product under work (e.g. Grafos) |
| Env | `🌐 web` for frontend work |
| Started At | creation date |

Apply defaults only when context makes them obvious; ask when ambiguous.
