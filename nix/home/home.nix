# Shared Home Manager config (NixOS module / macOS standalone).
#
# ~/.zshrc is managed here (source of truth: ./zshrc; the repo-root .zshrc is
# a symlink to it so the Makefile flow keeps working). The other config files
# (git, tmux, nvim, ...) stay managed by the Makefile symlinks in this repo.
{ pkgs, lib, inputs, ... }:

{
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.file.".zshrc".source = ./zshrc;

  home.packages = with pkgs; [
    # shell
    zsh
    starship # .config/starship.toml
    fzf # source <(fzf --zsh)
    bat # alias cat='bat'
    tree
    gomi # alias rm='gomi'

    # git
    git
    gh
    gh-dash # wired as a gh extension below; alias dash='gh dash'
    ghq
    (callPackage ./git-gtr.nix { }) # git gtr — worktree runner
    difftastic # git diff.external = difft

    # editor / terminal
    neovim # .config/nvim, .config/lua-nvim
    tmux # .config/tmux

    # kubernetes
    kubectl
    krew # krew.sh
    k9s

    # toolchains / runtimes
    rustup # .cargo/config.toml, RUSTUP_TOOLCHAIN=nightly
    mise # mise activate zsh
    bun
    python3 # serve()

    # AI agents
    claude-code # alias c='claude'
    codex # alias cx='codex'

    # crypto
    gnupg # gpg --card-status

    # agent multiplexer (.config/herdr) — from its upstream flake
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    pinentry-curses
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pinentry_mac
  ];

  # gh looks for extensions in ~/.local/share/gh/extensions, not on PATH;
  # wire gh-dash there so `gh dash` works without `gh extension install`.
  home.file.".local/share/gh/extensions/gh-dash/gh-dash".source =
    "${pkgs.gh-dash}/bin/gh-dash";
}
