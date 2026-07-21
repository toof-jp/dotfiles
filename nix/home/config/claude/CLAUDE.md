# Commit policy

All commits must be GPG-signed. Never commit with signing disabled (e.g. `--no-gpg-sign` or `commit.gpgsign=false`) — if signing fails, stop and report the error instead of working around it.

Before creating any commit, always have the staged changes reviewed by opencode first (e.g. `git diff --staged | opencode run "Review this diff and point out any problems"`). Address the issues it finds (or report them to the user) before committing.

# Merge / push policy

Never merge a pull request (via `gh pr merge`, `gh api`, the merge button, or any other means) without the user's explicit approval. Never push directly to `main` — always create a branch and open a pull request instead.

# PR comment policy

Never post comments on pull requests (review comments, inline comments, or replies via `gh pr comment`, `gh api`, etc.) without the user's explicit approval. Draft the comment and show it to the user first.

# Environment

Repositories are managed with [ghq](https://github.com/x-motemen/ghq), so this repo lives under `~/ghq/github.com/toof-jp/dotfiles` rather than a flat `~/dotfiles` path.

# Creating new GitHub repositories

New GitHub repositories under `toof-jp` are managed declaratively by [`toof-jp/github-repository-terraform`](https://github.com/toof-jp/github-repository-terraform) (`~/ghq/github.com/toof-jp/github-repository-terraform`). Do not create repositories via `gh repo create` or the web UI — instead, add a new entry to `repositories.json` in that repo and run `terraform apply` so the repo is created with the correct attributes and tracked in state.

# GHCR image publishing (CI)

When a repository needs CI that builds Docker images and pushes them to ghcr.io, follow the `ghcr-publish` skill (`~/.claude/skills/ghcr-publish/SKILL.md` — full workflow templates live there). Key rules:

- Detect Dockerfiles first, then pick the pattern:
  - One Dockerfile at repo root → single workflow `.github/workflows/build-push.yml`, image `ghcr.io/<owner>/<repo>`.
  - Multiple Dockerfiles in subdirectories (monorepo) → one workflow per service `.github/workflows/<service>-ci.yml`, image `ghcr.io/<owner>/<repo>-<service>`, with a `paths` filter covering both the service directory and the workflow file itself.
- Every workflow needs: `permissions: contents: read` + `packages: write`; `docker/setup-buildx-action`; `docker/login-action` with `${{ github.actor }}` / `${{ secrets.GITHUB_TOKEN }}`; `docker/metadata-action` with tags `latest` (default branch only) + `sha` + git tag and the `org.opencontainers.image.source` label; `docker/build-push-action` with `push: true`, `platforms: linux/amd64`, and GHA cache (`cache-from`/`cache-to: type=gha`).
- Verify the default branch name (`main` vs `master`) matches the repo.
- After writing workflows, run `pinact run` to pin actions and resolve any reported issues before finishing.

# Worktree management

Always start new work by creating a worktree with `git gtr new` first, then work inside it — never work directly in the main checkout.

Before creating a worktree, update `main` in the main checkout first (e.g. `git pull --ff-only` on `main`) so the new worktree branches off the latest `main`.

Use `git gtr` (git-worktree-runner) to create git worktrees instead of `git worktree add`.

```
git gtr new <branch>       # create a worktree for <branch>
git gtr rm <branch>        # remove it when done
git gtr ls                 # list worktrees
```

After a pull request is merged, remove its local worktree with `git gtr rm <branch>`.

Worktrees are created under `.worktrees/` inside the repo (`gtr.worktrees.dir = .worktrees`, set globally). This directory is ignored via the global gitignore (`.config/git/ignore`), so it never needs to be added per-repo.
