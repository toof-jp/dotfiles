# Commit policy

The user always commits with a GPG-signed key themselves. Claude Code must never run `git commit` (staging, diffing, and other git commands are fine). Prepare the change and let the user commit it.
