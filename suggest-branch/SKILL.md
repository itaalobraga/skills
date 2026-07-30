---
name: suggest-branch
description: Suggest Git branch names from a GitHub issue or task description.
argument-hint: "Issue URL or task summary; optional naming constraints"
disable-model-invocation: true
---

# Suggest branch

Suggest **scope-focused** Git branch names from a GitHub issue or task description. Return a short list plus one **recommendation**.

Use `gh` when the input is a GitHub issue URL.

## Collect before suggesting

Confirm or infer:

| Input | Required |
| --- | --- |
| Issue URL or task summary | yes |
| Include issue number in names | default: **no** |
| Language | default: **English** |
| Prefix preference (`feat/`, `fix/`, …) | infer from issue type |

When the user states constraints (e.g. "no number", "English only"), those override defaults.

## Legwork

### Issue URL

```bash
gh issue view NUMBER --repo OWNER/REPO --json title,body,labels
```

Extract: work type (feature, bugfix, refactor, chore), domain noun (routes, auth, …), and the core action (integrate, fix, migrate, …).

### Task description only

Infer the same fields from the user's text. Skip `gh`.

### Existing conventions (optional)

When a git repo is available, skim recent branch names:

```bash
git branch -a | head -30
```

Match prefix style and casing if a clear team pattern exists. Defaults below still apply when no pattern is found.

## Naming rules

Defaults unless the user overrides:

- **Scope-focused** — describe the work, not the ticket (`routes-api-integration`, not `18-routes-api`)
- **No issue number**
- **English** — kebab-case after the prefix
- **Prefix** by work type:
  - `feat/` — new capability or integration
  - `fix/` — bugfix
  - `refactor/` — structural change, same behavior
  - `chore/` — tooling, deps, CI
- **Length** — prefer 2–4 words after the prefix; drop filler (`the`, `page`, `update`)

## Output

Return **4–5** candidates, then one **Recommendation**.

```markdown
| Branch |
|--------|
| `feat/routes-api-integration` |
| `feat/connect-routes-page-to-api` |
| … |

**Recommendation:** `feat/routes-api-integration`

Brief reason — one sentence on scope coverage and brevity.
```

Rules:

- Scope-only table (no "when to use" column unless the user asked for comparison)
- Recommendation is the single best default pick, not a tie
- Link the issue when one was fetched

## Verify

Before responding:

- [ ] Every name is scope-focused and omits the issue number (unless user asked otherwise)
- [ ] Every name is English kebab-case with a valid prefix
- [ ] 4–5 candidates plus exactly one recommendation
- [ ] Recommendation reason references the issue scope, not generic git advice
