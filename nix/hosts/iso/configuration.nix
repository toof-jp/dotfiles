# Minimal installer ISO for the Intel NUC: boot + network + SSH only.
# Everything else is fetched over the network after booting:
#
#   nixos-install --flake 'github:toof-jp/dotfiles?dir=nix#<host>'
#
# installation-cd-minimal brings in: live nixos user, DHCP networking,
# openssh (enabled), installation tools.
{ modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # github.com/toof-jp.keys — SSH into the live environment without a console
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHWo3K3cd7yix7fvAkklAl11w+u0u+jYYgFcOsNBmpf"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIN8H2c3Qa2EsEh6RQG6nRoRFblH8fj5dHj9YyVD9tND"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUJhZJJtxQQzpQN23OAInodVNC1VT2ZAWtsyH0bPpVM"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVxr9QhV4fip8VAil6IZL+WsHtV55GJeD+yRw/8i/WO"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLZJDizwTJSPK1x4fO9GqrGVdTkG6s80UcX64vBlYDo"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHEKg+P0OX5pUPHiWOjecgemiZDBRiMjejO/z+oTZQy"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCD8d8Um1oUDliqkWvgdoOlgBU/+tjxl1GjkTgvSFPv"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrgBC/but8okN4/yhtvHcnhQEJCbE/9qEfdaPt1M6C7"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxEuii9kpBBeLSh31H8aROCRyJm1GeXtF3mXXZFzJYe"
  ];
}
