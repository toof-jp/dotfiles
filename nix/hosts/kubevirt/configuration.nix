# Dev VM running on KubeVirt (zen2). Built as a containerDisk qcow2.
#
# The nixpkgs kubevirt module brings in: qemu-guest profile, serial console,
# qemu-guest-agent, openssh, cloud-init (SSH keys are injected by the
# cloudInitNoCloud volume in the VirtualMachine manifest).
{ modulesPath, pkgs, ... }:

{
  imports = [ "${modulesPath}/virtualisation/kubevirt.nix" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "dev-vm";
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.zsh.enable = true;

  users.users.toof = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
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

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };

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
    vim
    git
    curl
    wget
  ];

  system.stateVersion = "25.11";
}
