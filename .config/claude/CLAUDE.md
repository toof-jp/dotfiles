# Commit policy

All commits must be GPG-signed. Never commit with signing disabled (e.g. `--no-gpg-sign` or `commit.gpgsign=false`) — if signing fails, stop and report the error instead of working around it.

# PR comment policy

Never post comments on pull requests (review comments, inline comments, or replies via `gh pr comment`, `gh api`, etc.) without the user's explicit approval. Draft the comment and show it to the user first.

# Environment

Repositories are managed with [ghq](https://github.com/x-motemen/ghq), so this repo lives under `~/ghq/github.com/toof-jp/dotfiles` rather than a flat `~/dotfiles` path.

# Worktree management

Always start new work by creating a worktree with `git gtr new` first, then work inside it — never work directly in the main checkout.

Use `git gtr` (git-worktree-runner) to create git worktrees instead of `git worktree add`.

```
git gtr new <branch>       # create a worktree for <branch>
git gtr rm <branch>        # remove it when done
git gtr ls                 # list worktrees
```

Worktrees are created under `.worktrees/` inside the repo (`gtr.worktrees.dir = .worktrees`, set globally). This directory is ignored via the global gitignore (`.config/git/ignore`), so it never needs to be added per-repo.
