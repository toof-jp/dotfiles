# Intel NUC: Kubernetes node (kubeadm) reachable over Tailscale.
#
# Install from the minimal ISO (nix build .#iso), partition with an ESP
# labeled BOOT (vfat) and a root labeled nixos (ext4), then:
#
#   nixos-install --flake 'github:toof-jp/dotfiles?dir=nix#nuc'
#
# After first boot: `tailscale up`, then `kubeadm join ...`.
{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Lets plain `sudo nixos-rebuild switch` work on the node (nixos-rebuild
  # picks up /etc/nixos/flake.nix and the attr matching the hostname).
  # Use `--refresh` to force-fetch the latest dotfiles.
  environment.etc."nixos/flake.nix".text = ''
    {
      inputs.dotfiles.url = "github:toof-jp/dotfiles?dir=nix";
      outputs = { dotfiles, ... }: {
        nixosConfigurations.nuc = dotfiles.nixosConfigurations.nuc;
      };
    }
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };
  # No swapDevices: kubelet refuses to run with swap enabled

  networking.hostName = "nuc";
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  services.tailscale.enable = true;
  networking.firewall = {
    # Cluster traffic flows over the tailnet; nothing but SSH on the LAN
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # --- kubeadm node ---------------------------------------------------
  # NixOS has no kubeadm module; this recreates what the upstream deb/rpm
  # packages set up: containerd (systemd cgroups), the kubelet unit with
  # kubeadm's drop-in semantics, kernel prerequisites, and CNI plugins in
  # a writable /opt/cni/bin (CNI DaemonSets copy their binaries there).

  boot.kernelModules = [ "br_netfilter" "overlay" ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
  };

  virtualisation.containerd = {
    enable = true;
    settings.plugins."io.containerd.grpc.v1.cri" = {
      containerd.runtimes.runc.options.SystemdCgroup = true;
      cni.bin_dir = "/opt/cni/bin";
    };
  };

  systemd.tmpfiles.rules = [
    "d /opt/cni/bin 0755 root root -"
    # C+ re-copies every boot so cni-plugins updates propagate; extra
    # binaries dropped in by CNI DaemonSets are left alone
    "C+ /opt/cni/bin - - - - ${pkgs.cni-plugins}/bin"
  ];

  systemd.services.kubelet = {
    description = "kubelet: The Kubernetes Node Agent";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "containerd.service" ];
    path = with pkgs; [
      util-linux
      iproute2
      iptables
      ethtool
      socat
      conntrack-tools
      cri-tools
      kubernetes
    ];
    # Mirrors kubeadm's 10-kubeadm.conf drop-in; the referenced files are
    # created by `kubeadm join`, so the unit keeps restarting until then
    environment = {
      KUBELET_KUBECONFIG_ARGS = "--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf";
      KUBELET_CONFIG_ARGS = "--config=/var/lib/kubelet/config.yaml";
    };
    serviceConfig = {
      ExecStart = "${pkgs.kubernetes}/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS";
      EnvironmentFile = [
        "-/var/lib/kubelet/kubeadm-flags.env"
        "-/etc/default/kubelet"
      ];
      Restart = "always";
      RestartSec = 10;
      CPUAccounting = true;
      MemoryAccounting = true;
    };
    unitConfig.StartLimitIntervalSec = 0;
  };

  environment.systemPackages = with pkgs; [
    kubernetes # kubeadm / kubelet / kubectl
    cri-tools
    git
    vim
  ];
  # --------------------------------------------------------------------

  programs.zsh.enable = true;

  users.users.toof = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    # github.com/toof-jp.keys
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
  # No password is set for toof (SSH keys only), so passwordless sudo is
  # the only way wheel can actually escalate
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
