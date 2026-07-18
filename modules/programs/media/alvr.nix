{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.alvr;
in
{
  options.myFeatures.programs.media.alvr = {
    enable = lib.mkEnableOption "ALVR (Air Light VR) Streamer";

    oculus = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable support for Oculus/Meta Quest headsets";
      };
    };

    pico = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable support for Pico headsets";
      };
    };

    vive = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable support and udev rules for HTC Vive headsets";
      };
    };

    valve = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable support and udev rules for Valve Index headsets";
      };
    };

    apple = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable support/optimizations for Apple Vision Pro";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.alvr = {
      enable = true;
      openFirewall = true;
    };

    # SteamVR is required for ALVR, so enable Steam support
    myFeatures.programs.media.steam.enable = lib.mkDefault true;

    # For Android-based headsets (Quest, Pico), we just need android-tools for adb wired/side-channel setup.
    # systemd 258 handles device uaccess rules automatically.
    environment.systemPackages = lib.optionals (cfg.oculus.enable || cfg.pico.enable) [
      pkgs.android-tools
    ];

    # For SteamVR/Lighthouse hardware (Vive, Valve Index), enable steam-hardware udev rules
    hardware.steam-hardware.enable = lib.mkIf (cfg.vive.enable || cfg.valve.enable) true;
  };
}
