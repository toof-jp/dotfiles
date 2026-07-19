# Config files managed by home-manager. The real files live in ./config; the
# repo-root .config/* entries are symlinks back here so the Makefile flow
# keeps working on machines without home-manager.
{ pkgs, lib, ... }:

{
  xdg.configFile = {
    "starship.toml".source = ./config/starship.toml;

    # ~/.config/git/gpg.config stays Makefile-managed (`make gpg`) so the
    # extra GPG bits remain per-machine opt-in; git ignores a missing include.
    "git/config".source = ./config/git/config;
    "git/ignore".source = ./config/git/ignore;

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
  };
}
