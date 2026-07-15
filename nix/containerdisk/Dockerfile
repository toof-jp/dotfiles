# KubeVirt containerDisk wrapping the NixOS qcow2 built from ../flake.nix.
# CI copies the qcow2 here as nixos.qcow2 before building (see
# .github/workflows/vm-image.yml); 107 is the qemu uid inside virt-launcher.
FROM scratch
ADD --chown=107:107 nixos.qcow2 /disk/nixos.qcow2
