# StarFive VisionFive 2 (4GB), riscv64. Minimal SD image: boot + WiFi + SSH
# only, so the (uncached, cross-compiled) closure stays small. Everything
# else gets pulled in later with nixos-rebuild on the board.
{ lib, inputs, ... }:

let
  # Real credentials live in the untracked wifi.nix (copy wifi.nix.example).
  # Untracked files are invisible to pure git-flake evaluation, so build with
  #   nix build "path:.#visionfive2-image"
  # Fall back to placeholders (with a warning) so `nix flake check` in CI,
  # which never sees the untracked file, can still evaluate this config.
  wifi =
    if builtins.pathExists ./wifi.nix then
      import ./wifi.nix
    else
      lib.warn
        "hosts/visionfive2/wifi.nix not found; using placeholder WiFi credentials (build via `nix build \"path:.#visionfive2-image\"` to include the untracked file)"
        (import ./wifi.nix.example);
in
{
  imports = [
    "${inputs.nixos-hardware}/starfive/visionfive/v2/sd-image.nix"
  ];

  nixpkgs.hostPlatform = "riscv64-linux";
  nixpkgs.buildPlatform = "x86_64-linux";

  # base.nix (pulled in by sd-image.nix) enables zfs/btrfs/etc; the sd image
  # only needs vfat + ext4, and zfs doesn't cross-build anyway
  boot.supportedFilesystems = lib.mkForce {
    vfat = true;
    ext4 = true;
  };

  documentation.enable = false;

  networking.hostName = "visionfive2";
  time.timeZone = "Asia/Tokyo";

  networking.useDHCP = true;
  networking.wireless = {
    enable = true;
    networks.${wifi.ssid}.psk = wifi.psk;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.toof = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIN8H2c3Qa2EsEh6RQG6nRoRFblH8fj5dHj9YyVD9tND toof@toof.jp"
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  sdImage.compressImage = false;

  # Do not change after the first install.
  system.stateVersion = "25.11";
}
