# Commit policy

The user always commits with a GPG-signed key themselves. Claude Code must never run `git commit` (staging, diffing, and other git commands are fine). Prepare the change and let the user commit it.

# Environment

Repositories are managed with [ghq](https://github.com/x-motemen/ghq), so this repo lives under `~/ghq/github.com/toof-jp/dotfiles` rather than a flat `~/dotfiles` path.
