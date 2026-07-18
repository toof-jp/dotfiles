{
  description = "toof's dev environment (NixOS + Home Manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
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

        # Dev VM on KubeVirt (zen2): full config, applied from inside the
        # VM with nixos-rebuild (the shipped image only contains kubevirt-base)
        kubevirt = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/kubevirt/configuration.nix ] ++ homeManagerModules;
        };

        # What actually gets baked into the qcow2: boot + SSH only, so the
        # slow cptofs step in the image build stays small
        kubevirt-base = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/kubevirt/base.nix ];
        };
      };

      # Minimal qcow2 for KubeVirt:
      #   nix build .#kubevirt-image
      # Sized to the closure: large virtual sizes make cptofs OOM/thrash
      # inside its 100MB LKL kernel. CDI expands the disk to the PVC size on
      # import, and growPartition/autoResize (from the kubevirt module) grow
      # the root fs on first boot.
      packages.x86_64-linux.kubevirt-image =
        import (nixpkgs + "/nixos/lib/make-disk-image.nix") {
          inherit (self.nixosConfigurations.kubevirt-base) config pkgs;
          lib = nixpkgs.lib;
          format = "qcow2";
          diskSize = "auto";
          additionalSpace = "2048M"; # slack until the first-boot resize
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
