# Config files managed by home-manager. The real files live in ./config; the
# repo-root .config/* entries are symlinks back here so the Makefile flow
# keeps working on machines without home-manager.
#
# signingKey is passed via extraSpecialArgs in flake.nix and is the literal
# `key::ecdsa-sha2-nistp256 ...` string for the machine's Secretive key.
{ pkgs, lib, signingKey, ... }:

{
  xdg.configFile = {
    "starship.toml".source = ./config/starship.toml;

    # ~/.config/git/gpg.config stays Makefile-managed (`make gpg`) so the
    # extra GPG bits remain per-machine opt-in; git ignores a missing include.
    # git/config is generated (not sourced) so the signing key can be injected
    # per machine via signingKey from flake.nix extraSpecialArgs.
    "git/config".text = ''
      [core]
        quotepath = false
      [init]
        defaultBranch = main

      [user]
        name = Fumiya Tokumasu
        email = toof@toof.jp
        signingkey = ${signingKey}

      [gpg]
        format = ssh

      [gpg "ssh"]
        allowedSignersFile = ~/.config/git/allowed_signers

      [push]
        autoSetupRemote = true

      [alias]
        pull = pull --all

      [diff]
        external = difft

      [include]
        path = ~/.config/git/gpg.config
      [commit]
        gpgsign = true
      [gtr "worktrees"]
        dir = .worktrees
    '';
    "git/ignore".source = ./config/git/ignore;
    "git/allowed_signers".source = ./config/git/allowed_signers;

    "rustfmt".source = ./config/rustfmt;

    "herdr/config.toml".source = ./config/herdr/config.toml;

    "ghostty/config".source = ./config/ghostty/config;
  };

  home.file = {
    # Claude Code reads its user-level config from ~/.claude (CLAUDE_CONFIG_DIR
    # is unset), not $XDG_CONFIG_HOME/claude.
    # Note: these become read-only store symlinks; Claude Code can no longer
    # write settings.json in place.
    ".claude/settings.json".source = ./config/claude/settings.json;
    ".claude/CLAUDE.md".source = ./config/claude/CLAUDE.md;
    ".claude/skills".source = ./config/claude/skills;

    # pinentry-program in this file is the homebrew mac path, so only deploy on
    # darwin; the NixOS hosts configure gpg-agent via programs.gnupg.agent.
    ".gnupg/gpg-agent.conf" = lib.mkIf pkgs.stdenv.isDarwin {
      source = ./config/gnupg/gpg-agent.conf;
    };

    # Non-Darwin hosts receive gpg SSH-forwarded from a Mac (see
    # .ssh/config.mac RemoteForward of S.gpg-agent). Without no-autostart,
    # invoking `gpg` spawns a local gpg-agent + scdaemon that rebind the
    # forwarded socket and break `gpg --card-status`. zshrc launches the
    # agent explicitly for non-SSH sessions, so local usage still works.
    ".gnupg/gpg.conf" = lib.mkIf (!pkgs.stdenv.isDarwin) {
      source = ./config/gnupg/gpg.conf;
    };
  };
}
