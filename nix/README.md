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

### Dev VM on KubeVirt (zen2)

The VM boots a minimal image (`.#kubevirt-image`, built from
`nixosConfigurations.kubevirt-base`) that CDI imports from
`gs://toof-infra-vm-images/nixos-dev.qcow2`; manifests live in
toof-jp/infra `kubernetes/applications/dev-vm`. Apply the full dev config
from inside the VM:

```sh
sudo nixos-rebuild switch --flake 'github:toof-jp/dotfiles?dir=nix#kubevirt'
```

To ship a new image:

```sh
nix build ./nix#kubevirt-image
gcloud storage cp result/nixos.qcow2 gs://toof-infra-vm-images/nixos-dev.qcow2
# then delete the dev-root DataVolume in the cluster to re-import
```

## Notes

- `claude-code` has an unfree license, so `allowUnfree = true` is set.
- `herdr` is not in nixpkgs; it is installed from its upstream flake
  (github:ogulcancelik/herdr).
