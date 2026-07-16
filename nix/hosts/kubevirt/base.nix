# Minimal KubeVirt image: just enough to boot, mount /home, and SSH in.
# The image build time is dominated by cptofs copying the closure, so this
# stays small; apply the full config from inside the VM afterwards:
#
#   sudo nixos-rebuild switch --flake 'github:toof-jp/dotfiles?dir=nix#kubevirt'
#
# The nixpkgs kubevirt module brings in: qemu-guest profile, serial console,
# qemu-guest-agent, openssh, cloud-init.
{ modulesPath, pkgs, ... }:

{
  imports = [ "${modulesPath}/virtualisation/kubevirt.nix" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "dev-vm";
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.zsh.enable = true;

  users.users.toof = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    # github.com/toof-jp.keys — also injected via cloud-init, but baked in
    # so SSH works even if the datasource is missing
    openssh.authorizedKeys.keys = [
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
  };
  # containerDisk root is ephemeral; no local secrets to protect and the VM
  # is only reachable inside the cluster
  security.sudo.wheelNeedsPassword = false;

  # /home lives on a Longhorn PVC (virtio disk with serial "home"),
  # formatted on first boot so it survives VM restarts
  fileSystems."/home" = {
    device = "/dev/disk/by-id/virtio-home";
    fsType = "ext4";
    autoFormat = true;
    autoResize = true;
    options = [ "nofail" ];
  };

  environment.systemPackages = with pkgs; [
    git # needed for the flake rebuild
    vim
  ];

  system.stateVersion = "25.11";
}
