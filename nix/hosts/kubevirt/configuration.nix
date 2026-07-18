# Full dev VM config, applied from inside the VM (the shipped image only
# contains base.nix — see the comment there).
{ pkgs, ... }:

{
  imports = [ ./base.nix ];

  # Lets plain `sudo nixos-rebuild switch` work inside the VM (nixos-rebuild
  # picks up /etc/nixos/flake.nix and the attr matching the hostname).
  # Use `--refresh` to force-fetch the latest dotfiles; the github tarball
  # is otherwise cached for a while.
  environment.etc."nixos/flake.nix".text = ''
    {
      inputs.dotfiles.url = "github:toof-jp/dotfiles?dir=nix";
      outputs = { dotfiles, ... }: {
        nixosConfigurations.dev-vm = dotfiles.nixosConfigurations.kubevirt;
      };
    }
  '';

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.users.toof.extraGroups = [ "docker" ];

  # First time: sudo tailscale up
  services.tailscale.enable = true;

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
