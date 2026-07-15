# PLACEHOLDER — replace with the generated file on the actual machine:
#
#   sudo nixos-generate-config
#   cp /etc/nixos/hardware-configuration.nix nix/hosts/dev/
#
# The values below only exist so the flake evaluates; they will not boot.
{ lib, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
