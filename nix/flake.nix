{
  description = "toof's dev environment (NixOS + Home Manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Upstream pins nixos-unstable + rust-overlay toolchain; intentionally
    # not following our nixpkgs so it builds exactly as upstream CI tests it.
    herdr.url = "github:ogulcancelik/herdr";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      username = "toof";

      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true; # claude-code etc.
      };

      homeManagerModules = [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.${username} = import ./home/home.nix;
        }
      ];

      # Standalone home-manager (macOS and non-NixOS Linux)
      mkHome = { system, homeDirectory, extraModules ? [ ] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/home.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        dev = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/dev/configuration.nix ] ++ homeManagerModules;
        };

        # Dev VM on KubeVirt (zen2)
        kubevirt = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/kubevirt/configuration.nix ] ++ homeManagerModules;
        };
      };

      # qcow2 for the KubeVirt containerDisk:
      #   nix build .#kubevirt-image
      # 64 GiB virtual size (sparse, so the file only stores written data).
      packages.x86_64-linux.kubevirt-image =
        import (nixpkgs + "/nixos/lib/make-disk-image.nix") {
          inherit (self.nixosConfigurations.kubevirt) config pkgs;
          lib = nixpkgs.lib;
          format = "qcow2";
          diskSize = 65536; # MiB
        };

      homeConfigurations = {
        # Apple Silicon Mac: nix run home-manager -- switch --flake .#toof@mac
        "${username}@mac" = mkHome {
          system = "aarch64-darwin";
          homeDirectory = "/Users/${username}";
        };

        # Non-NixOS Linux (Arch, WSL, ...): nix run home-manager -- switch --flake .#toof@linux
        "${username}@linux" = mkHome {
          system = "x86_64-linux";
          homeDirectory = "/home/${username}";
          extraModules = [
            # session vars / XDG integration for distros other than NixOS
            { targets.genericLinux.enable = true; }
          ];
        };
      };
    };
}
