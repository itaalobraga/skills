# create-issue — reference

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
