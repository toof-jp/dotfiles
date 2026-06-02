---
name: ghcr-publish-action
description: Write or update GitHub Actions workflows that build Docker images and push to GitHub Container Registry (ghcr.io). Use when a repository needs CI image publishing, especially when Dockerfile location must be detected first (repo root vs nested directory/monorepo), and when configuring docker/build-push-action with the correct context and file path.
---

# Ghcr Publish Action

Use this workflow when implementing GHCR publish CI.

## Workflow

1. Detect Dockerfile location before writing Actions.
2. Choose one of two templates:
   - Dockerfile at repo root
   - Dockerfile in nested directory (monorepo)
3. Create `.github/workflows/ghcr.yml`.
4. Set permissions, login, metadata, and build/push config.
5. Verify `context` and `file` values match the detected Dockerfile path.
6. Run `pinact run` as the final step after writing the workflow.

## Step 1: Detect Dockerfile

Run:

```bash
find . -name Dockerfile -type f
```

Decision:

- If `./Dockerfile` exists and target app is root: use root template.
- If target app Dockerfile is under subdirectory: use nested template and set `context`/`file` to that directory.

## Required Action Structure

- `permissions`: include `contents: read` and `packages: write`
- `docker/login-action@v3`: use `${{ github.actor }}` and `${{ secrets.GITHUB_TOKEN }}`
- `docker/metadata-action@v5`: generate tags for `ghcr.io/<owner>/<image>`
- `docker/build-push-action@v6`: `push: true`

## Template: Root Dockerfile Pattern

Use when Dockerfile is `./Dockerfile` (example: `../npm-download-stats-otel-exporter`).

```yaml
name: Publish to GHCR

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  packages: write

jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository_owner }}/<image-name>
          tags: |
            type=ref,event=branch
            type=sha

      - uses: docker/build-push-action@v6
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

## Template: Nested Dockerfile Pattern

Use when Dockerfile is in subdirectory (example: `../bbs` monorepo).

```yaml
name: Publish to GHCR

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  packages: write

jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository_owner }}/<image-name>
          tags: |
            type=ref,event=branch
            type=sha

      - uses: docker/build-push-action@v6
        with:
          context: ./<service-dir>
          file: ./<service-dir>/Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

## Final Checks

- Confirm target image name is explicit and stable.
- Confirm default branch name (`main` or `master`) matches repository.
- Confirm repository settings allow `GITHUB_TOKEN` package write for GHCR.
- Run `pinact run` and resolve reported issues before finishing.
