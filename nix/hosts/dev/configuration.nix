# NixOS dev machine.
{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "dev";
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.zsh.enable = true;

  users.users.toof = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 ..." ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  virtualisation.docker = {
    enable = true;
    # default docker 28.x is marked insecure in nixos-25.11
    package = pkgs.docker_29;
  };

  # YubiKey / smartcard (gpg --card-status)
  services.pcscd.enable = true;
  programs.gnupg.agent.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  # Do not change after the first install.
  system.stateVersion = "25.11";
}
