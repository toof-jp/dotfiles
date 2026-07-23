# nix

Dev environment built with NixOS + Home Manager. Nix installs the packages;
config files (.zshrc, git, tmux, nvim, ...) are still managed by the Makefile
symlinks at the repo root (`make all`).

## Layout

```
nix/
├── flake.nix                 # inputs: nixos-25.11 + home-manager release-25.11 + herdr
├── home/home.nix             # shared Home Manager config (packages only)
├── modules/                  # shared NixOS modules (k8s node, VPS installer)
└── hosts/
    ├── dev/                  # main workstation
    ├── kubevirt/             # dev VM on KubeVirt (zen2)
    ├── nuc/                  # Intel NUC k8s control-plane
    ├── iso/                  # minimal installer ISO for NUC
    ├── visionfive2/          # StarFive VisionFive 2 (riscv64) SD image
    ├── sakura-vps/           # Sakura VPS k8s control-plane + installer ISO
    ├── vultr-vps/            # Vultr VPS k8s node + installer ISO
    └── oci-vps/              # OCI E2.1.Micro k8s node (nixos-infect-converted)
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

### VPS k8s nodes (sakura / vultr / oci)

Cheap-VPS kubeadm nodes joining the zen2 tailnet cluster. No Home Manager
(too heavy for a 1–2 GB VPS); shared bits live in `modules/k8s-vps.nix` and
`modules/kubernetes-node.nix`. Each host owns its hostname, tailscale
`nodeIP`, `network.nix`, and `hardware-configuration.nix`.

```sh
# Build a provider installer ISO (sakura/vultr):
nix build ./nix#sakura-installer-iso
nix build ./nix#vultr-installer-iso

# Then boot it in the VPS's control panel and run the baked-in installer:
sakura-install   # or vultr-install — wipes /dev/vda and runs nixos-install
```

OCI's E2.1.Micro can't boot custom ISOs, so `oci-vps` was converted in
place with nixos-infect — there is no `oci-installer`. See
`hosts/sakura-vps/README.md` for the full sakura bring-up procedure
(tailscale up, kubeadm join, etc.).

`kubernetes` / `cri-tools` come from nixpkgs-unstable via
`kubernetesOverlayModule` so every kubeadm node (nuc + all VPSs) stays on
the same minor — nixos-25.11 lags at 1.34 while our cluster is on 1.36.

## Notes

- `claude-code` has an unfree license, so `allowUnfree = true` is set.
- `herdr` is not in nixpkgs; it is installed from its upstream flake
  (github:ogulcancelik/herdr).
