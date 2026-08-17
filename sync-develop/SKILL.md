---
name: sync-develop
description: Check out develop, pull, and delete the local feature branch in the repos that just landed.
argument-hint: "optional repo paths"
disable-model-invocation: true
---

# Sync develop

Return landed feature repos to `develop`: pull, then delete the local feature branch.

## Repos

| Input | Default |
| conversation's feature repos, or paths the user named | required |

Completion: every path is a git repo, and the set shares **one** feature-branch name (or is already on `develop`). More than one feature-branch name → list `path + branch` and stop.

## Per repo

Working tree clean (`git status --porcelain` empty). Dirty → report that repo and skip it.

From this skill directory:

```bash
scripts/sync-develop.sh /absolute/path/to/repo
```

Completion: stdout is `already on develop (...); pulled` or `develop (...); deleted local <branch>`. Non-zero → report stderr; leave that repo as-is.

## Report

One line per repo, in the user's language.

## Verify

- [ ] Every targeted repo is on `develop` and pulled
- [ ] Local feature branch gone where `branch -d` succeeded
- [ ] Remotes unchanged
