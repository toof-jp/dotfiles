# `kimi` — Claude Code backed by Moonshot's Kimi K3 via its
# Anthropic-compatible endpoint. The API key is read from 1Password at
# launch (override the item with $KIMI_OP_ITEM), so nothing lands on disk.
#
# `op` is intentionally NOT a runtime input: the one on PATH is the
# op-sa-wrapper (~/.cargo/bin/op, from toof-jp/op-sa-wrapper), which
# injects the GPG-encrypted service-account token before delegating to
# the real CLI. Shipping nixpkgs' op here would shadow it.
{ writeShellApplication, claude-code }:

writeShellApplication {
  name = "kimi";
  runtimeInputs = [ claude-code ];
  text = ''
    : "''${KIMI_OP_ITEM:=op://infra/Moonshot/credential}"

    export ANTHROPIC_BASE_URL="https://api.moonshot.ai/anthropic"
    ANTHROPIC_AUTH_TOKEN="$(op read "$KIMI_OP_ITEM")"
    export ANTHROPIC_AUTH_TOKEN
    export ANTHROPIC_MODEL="kimi-k3"
    export ANTHROPIC_SMALL_FAST_MODEL="kimi-k3"
    unset ANTHROPIC_API_KEY

    exec claude "$@"
  '';
  meta.description = "Claude Code wrapper running on Moonshot Kimi K3";
}
