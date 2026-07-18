# Shared Home Manager config (NixOS module / macOS standalone).
#
# ~/.zshrc and the configs in ./config (git, gnupg, rustfmt, claude, herdr,
# starship — see ./configs.nix) are managed here; the repo-root .zshrc and
# .config/* entries are symlinks back so the Makefile flow keeps working.
# The remaining config files (tmux, nvim, ssh, ...) stay Makefile-managed.
{ pkgs, lib, inputs, ... }:

{
  imports = [
    ./configs.nix
    ./nixvim.nix
  ];

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.file.".zshrc".source = ./zshrc;

  # .zshrc sources ~/.zsh/git-prompt.sh; the Makefile curls it from git
  # upstream, but on nix-managed machines ship the one bundled with git.
  home.file.".zsh/git-prompt.sh".source =
    "${pkgs.git}/share/git/contrib/completion/git-prompt.sh";

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

  # gh looks for extensions in ~/.local/share/gh/extensions, not on PATH;
  # wire gh-dash there so `gh dash` works without `gh extension install`.
  home.file.".local/share/gh/extensions/gh-dash/gh-dash".source =
    "${pkgs.gh-dash}/bin/gh-dash";
}
