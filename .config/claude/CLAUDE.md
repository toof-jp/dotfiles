# Commit policy

The user always commits with a GPG-signed key themselves. Claude Code must never run `git commit` (staging, diffing, and other git commands are fine). Prepare the change and let the user commit it.

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
