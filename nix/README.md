# nix

Dev environment built with NixOS + Home Manager. Nix installs the packages;
config files (.zshrc, git, tmux, nvim, ...) are still managed by the Makefile
symlinks at the repo root (`make all`).

## Layout

```
nix/
├── flake.nix                 # inputs: nixos-25.11 + home-manager release-25.11 + herdr
├── home/home.nix             # shared Home Manager config (packages only)
└── hosts/dev/
    ├── configuration.nix     # NixOS system config
    └── hardware-configuration.nix  # placeholder — generate on the real machine
```

## Usage

### NixOS

```sh
# First time: generate hardware-configuration.nix on the machine and put it
# in hosts/dev/, then:
sudo nixos-rebuild switch --flake ~/ghq/github.com/toof-jp/dotfiles/nix#dev
```

Home Manager is wired in as a NixOS module (`home-manager.users.toof`).

### macOS / non-NixOS Linux (standalone Home Manager)

```sh
# mac (Apple Silicon)
nix run home-manager -- switch --flake ~/ghq/github.com/toof-jp/dotfiles/nix#toof@mac

# Linux (Arch, WSL, ...)
nix run home-manager -- switch --flake ~/ghq/github.com/toof-jp/dotfiles/nix#toof@linux
```

After the first run, `home-manager switch --flake .#toof@mac` is enough.

### Updating

```sh
nix flake update         # update all inputs in flake.lock
nix flake update herdr   # update a single input
```

## Notes

- `claude-code` has an unfree license, so `allowUnfree = true` is set.
- `herdr` is not in nixpkgs; it is installed from its upstream flake
  (github:ogulcancelik/herdr).
