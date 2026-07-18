---
name: ghcr-publish
description: Write GitHub Actions workflows that build Docker images and push them to GitHub Container Registry (ghcr.io). Use when a repository needs CI image publishing. Detects whether the repo is single-container (one Dockerfile at root) or multi-container (monorepo with multiple services), and generates one workflow per image with correct context, paths filter, and tags.
---

# GHCR Publish CI

GitHub Actions workflow を書いて Docker イメージをビルドし GHCR に push する。

## Workflow

1. Dockerfile の場所を検出する:

   ```bash
   find . -name Dockerfile -not -path '*/node_modules/*' -not -path '*/.git/*'
   ```

2. パターンを選ぶ:
   - Dockerfile がリポジトリルートに 1 つ → **単一コンテナパターン**（1 ファイル `.github/workflows/build-push.yml`）
   - Dockerfile がサブディレクトリに複数 → **マルチコンテナパターン**（サービスごとに `.github/workflows/<service>-ci.yml` を作成）
3. イメージ名を決める:
   - 単一コンテナ: `ghcr.io/<owner>/<repo>`（またはアプリ固有の名前）
   - マルチコンテナ: `ghcr.io/<owner>/<repo>-<service>`（例: `bbs-mcp-server`, `bbs-search-backend`）
4. デフォルトブランチ名（`main` / `master`）がリポジトリと一致しているか確認する。
5. マルチコンテナでは `paths` フィルタに **サービスのディレクトリと workflow ファイル自身** の両方を含める。
6. 書き終えたら `pinact run` を実行して action の pin を解決する。

## 共通の必須要素

- `permissions`: `contents: read` と `packages: write`
- `docker/setup-buildx-action@v3` で Buildx をセットアップ
- `docker/login-action@v3`: `${{ github.actor }}` + `${{ secrets.GITHUB_TOKEN }}`
- `docker/metadata-action@v5`: tags は `latest`（デフォルトブランチのみ）+ `sha` + git tag、labels に `org.opencontainers.image.source`
- `docker/build-push-action@v6`: `push: true`, `platforms: linux/amd64`, GHA キャッシュ（`cache-from`/`cache-to: type=gha`）

## Template: 単一コンテナ（例: currency-exchange-discord-bot）

`.github/workflows/build-push.yml`:

```yaml
name: Build & Push to GHCR

on:
  push:
    branches: [ main ]

permissions:
  contents: read
  packages: write

env:
  IMAGE_NAME: ghcr.io/${{ github.repository_owner }}/<image-name>

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v5

      - name: Set up Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata (tags, labels)
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.IMAGE_NAME }}
          tags: |
            type=raw,value=latest,enable={{is_default_branch}}
            type=sha,enable=true
            type=ref,event=tag
          labels: |
            org.opencontainers.image.source=${{ github.server_url }}/${{ github.repository }}

      - name: Build & Push
        uses: docker/build-push-action@v6
        with:
          platforms: linux/amd64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Template: マルチコンテナ / monorepo（例: bbs）

サービスごとに `.github/workflows/<service>-ci.yml` を 1 ファイルずつ作る:

```yaml
name: Build & Push to GHCR

on:
  push:
    branches: [ main ]
    paths:
      - <service-dir>/**
      - .github/workflows/<service>-ci.yml

permissions:
  contents: read
  packages: write

env:
  IMAGE_NAME: ghcr.io/${{ github.repository_owner }}/<repo>-<service>

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v5

      - name: Set up Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata (tags, labels)
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.IMAGE_NAME }}
          tags: |
            type=raw,value=latest,enable={{is_default_branch}}
            type=sha,enable=true
            type=ref,event=tag
          labels: |
            org.opencontainers.image.source=${{ github.server_url }}/${{ github.repository }}

      - name: Build & Push
        uses: docker/build-push-action@v6
        with:
          context: <service-dir>
          file: <service-dir>/Dockerfile
          platforms: linux/amd64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

`<service-dir>` はネストしていてもよい（例: `search/backend` → イメージ名 `bbs-search-backend`、workflow 名 `search-backend-ci.yml`）。

## Final Checks

- `context` / `file` が検出した Dockerfile のパスと一致しているか。
- マルチコンテナの場合、`paths` フィルタと workflow ファイル名がサービスごとに正しいか。
- イメージ名が明示的で安定しているか。
- `pinact run` を実行し、報告された問題を解決してから完了とする。
