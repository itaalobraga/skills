# create-issue — reference

## gh access

Minimum for the **GitHub branch**: logged-in `gh`, **write** on `orbe-soft/orbe-development-board`, **update** on the target Project V2. Org SSO must be authorized on the token when the org requires it.

Classic PAT / `gh auth login` scopes: `repo`, `project`. Fine-grained: Issues **Read and write** on the board repo; Organization projects **Read and write**.

Refresh scopes: `gh auth refresh -s repo,project -h github.com`

### Binary probe

Run after inputs are collected and the body is drafted. **All** checks must succeed. Any failure → **local branch** only (no issue created on GitHub).

**1. CLI session**

```bash
gh auth status
```

**2. Board repo — create issues**

```bash
gh api graphql -f query='
query {
  repository(owner: "orbe-soft", name: "orbe-development-board") {
    viewerPermission
  }
}'
```

Pass when `viewerPermission` is `WRITE`, `MAINTAIN`, or `ADMIN`.

**3. Project — add items and set fields**

Use `organization` or `user` to match the collected project owner.

```bash
gh api graphql -f query='
query($owner: String!, $num: Int!) {
  organization(login: $owner) {
    projectV2(number: $num) { viewerCanUpdate }
  }
}' -f owner=OWNER -F num=PROJECT_NUMBER
```

For user-owned projects, replace `organization(login: $owner)` with `user(login: $owner)`.

Pass when `viewerCanUpdate` is `true`.

Map common failures to one user-facing line: not logged in; SSO not authorized; missing `project` scope; no repo write; no project update access.

## Discover project item ID

```bash
gh api graphql -f query='
query($org: String!, $num: Int!) {
  organization(login: $org) {
    projectV2(number: $num) {
      id
      items(first: 50) {
        nodes {
          id
          content { ... on Issue { number } }
        }
      }
    }
  }
}' -f org=OWNER -F num=PROJECT_NUMBER
```

Use `user(login: …)` instead of `organization` for user-owned projects.

## Set a single-select project field

```bash
gh api graphql -f query='
mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
  updateProjectV2ItemFieldValue(input: {
    projectId: $projectId
    itemId: $itemId
    fieldId: $fieldId
    value: { singleSelectOptionId: $optionId }
  }) {
    projectV2Item { id }
  }
}' -f projectId=PROJECT_ID -f itemId=ITEM_ID -f fieldId=FIELD_ID -f optionId=OPTION_ID
```

Resolve `optionId` from `gh project field-list … --format json` → `fields[].options[]` where `name` matches (e.g. `to do`, `Grafos`, `🌐 web`).

## Set a date project field

```bash
gh api graphql -f query='
mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $date: Date!) {
  updateProjectV2ItemFieldValue(input: {
    projectId: $projectId
    itemId: $itemId
    fieldId: $fieldId
    value: { date: $date }
  }) {
    projectV2Item { id }
  }
}' -f projectId=PROJECT_ID -f itemId=ITEM_ID -f fieldId=FIELD_ID -f date=2026-07-20
```

## List issue types

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!) {
  repository(owner: $owner, name: $repo) {
    issueTypes(first: 20) { nodes { id name } }
  }
}' -f owner=OWNER -f repo=REPO
```

## Set issue type

```bash
gh api graphql -f query='
mutation($issueId: ID!, $issueTypeId: ID!) {
  updateIssue(input: { id: $issueId, issueTypeId: $issueTypeId }) {
    issue { number issueType { name } }
  }
}' -f issueId=ISSUE_NODE_ID -f issueTypeId=TYPE_ID
```

Issue node ID:

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $num: Int!) {
  repository(owner: $owner, name: $repo) {
    issue(number: $num) { id issueType { name } }
  }
}' -f owner=OWNER -f repo=REPO -F num=NUMBER
```

## Verify project fields on an item

```bash
gh api graphql -f query='
query($org: String!, $num: Int!, $issueNum: Int!) {
  organization(login: $org) {
    projectV2(number: $num) {
      items(first: 50) {
        nodes {
          content { ... on Issue { number } }
          fieldValues(first: 20) {
            nodes {
              ... on ProjectV2ItemFieldSingleSelectValue {
                name field { ... on ProjectV2FieldCommon { name } }
              }
              ... on ProjectV2ItemFieldDateValue {
                date field { ... on ProjectV2FieldCommon { name } }
              }
            }
          }
        }
      }
    }
  }
}' -f org=OWNER -F num=PROJECT_NUMBER
```

Filter the node where `content.number` equals the issue number.

## Orbe issue template

https://github.com/orbe-soft/.github/blob/main/.github/ISSUE_TEMPLATE/new-issue.md

```markdown
<img src="https://orbesoft.com.br/logo.svg" alt="Descrição" width="86" height="24" />

## 📝 Descrição

## 🎯 Requisitos

## ✅ Critérios de Aceitação

## 🔗 Referências
```
