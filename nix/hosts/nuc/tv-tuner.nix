# Home ISDB-T recording stack: PLEX PX-S1UD x4 tuners + ACS ACR39U B-CAS
# reader. Kernel drivers (smsusb / smsdvb) come with linux-firmware but the
# smsdvb Siano Rio firmware is not redistributed by upstream, so we pull it
# out of PLEX's Windows driver zip and place it via hardware.firmware.
{ config, pkgs, lib, ... }:

let
  px-s1ud-firmware = pkgs.stdenvNoCC.mkDerivation {
    pname = "px-s1ud-firmware";
    version = "1.0.1";

    src = pkgs.fetchurl {
      url = "http://www.plex-net.co.jp/plex/px-s1ud/PX-S1UD_driver_Ver.1.0.1.zip";
      sha256 = "05p963vc3x7spa3gn7hyiygg1b308ljvvm1nnbhah55921icx7ql";
    };

    nativeBuildInputs = [ pkgs.unzip ];
    dontConfigure = true;
    dontBuild = true;

    # stdenv's unpackPhase cd's into PX-S1UD_driver_Ver.1.0.1/ (the single
    # top-level directory in the zip), so the path is relative to that.
    installPhase = ''
      runHook preInstall
      install -Dm444 x64/amd64/isdbt_rio.inp \
        $out/lib/firmware/isdbt_rio.inp
      runHook postInstall
    '';

    meta = with lib; {
      description = "Firmware for PLEX PX-S1UD (Siano Rio smsdvb) ISDB-T USB tuner";
      homepage = "http://www.plex-net.co.jp/plex/px-s1ud/";
      license = licenses.unfreeRedistributable;
      platforms = platforms.linux;
    };
  };
in
{
  nixpkgs.config.allowUnfree = true;

  hardware.firmware = [ px-s1ud-firmware ];

  # smsusb/smsdvb are auto-loaded by udev on device probe, but list them
  # explicitly so they're pinned into the initrd search path and so a
  # rebuild that changes the kernel keeps them available.
  boot.kernelModules = [ "smsusb" "smsdvb" ];

  # ACS ACR39U is a CCID reader; pcscd + libccid is enough. mirakc reaches
  # the daemon through /run/pcscd/pcscd.comm mounted into the pod.
  services.pcscd = {
    enable = true;
    plugins = [ pkgs.ccid ];
  };

  environment.systemPackages = with pkgs; [
    pcsc-tools   # pcsc_scan for reader diagnostics
    v4l-utils    # dvbv5-zap for tuning diagnostics
  ];
}
