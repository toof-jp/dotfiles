# Full dev VM config, applied from inside the VM (the shipped image only
# contains base.nix — see the comment there).
{ pkgs, ... }:

{
  imports = [ ./base.nix ];

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.users.toof.extraGroups = [ "docker" ];

  virtualisation.docker = {
    enable = true;
    # default docker 28.x is marked insecure in nixos-25.11
    package = pkgs.docker_29;
  };

  environment.systemPackages = with pkgs; [
    curl
    wget
  ];
}
