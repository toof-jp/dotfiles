# Shared Home Manager config (NixOS module / macOS standalone).
#
# Packages only: config files (.zshrc, git, tmux, nvim, ...) stay managed by
# the Makefile symlinks in this repo, so nothing here writes into ~/.config.
{ pkgs, lib, inputs, ... }:

{
  imports = [ ./nixvim.nix ];

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

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
    ghq
    difftastic # git diff.external = difft

    # editor / terminal
    # Plain neovim stays for the NVIM_APPNAME-based configs (.config/nvim /
    # .config/lua-nvim, aliases ov / v). nixvim (see ./nixvim.nix) also ships
    # a bin/nvim; hiPrio lets this one win the `nvim` name, the nixvim build
    # is available as `nixvim`.
    (lib.hiPrio neovim)
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
}
