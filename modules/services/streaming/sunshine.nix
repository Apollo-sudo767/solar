{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.streaming.sunshine;
in
{
  options.myFeatures.services.streaming.sunshine = {
    enable = lib.mkEnableOption "Sunshine: Open-source GameStream host";
    port = lib.mkOption {
      type = lib.types.port;
      default = 47990;
      description = "The port for the Sunshine Web UI";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # 1. Platform-agnostic settings
    {
      environment.systemPackages = with pkgs; [ sunshine miniupnpc ];
    }

    # 2. Linux-only settings (Guarded to prevent macOS from seeing 'boot')
    (lib.mkIf pkgs.stdenv.isLinux {
      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = false;
      };

      networking.firewall = {
        allowedTCPPorts = [ 47984 47989 48010 cfg.port ];
        allowedUDPPorts = [ 1900 5353 48010 ];
        allowedUDPPortRanges = [
          { from = 47998; to = 48000; }
          { from = 8000; to = 8010; }
        ];
      };

      boot.kernelModules = [ "uinput" ];
      hardware.uinput.enable = true;
      users.users.apollo.extraGroups = [ "uinput" ];

      environment.systemPackages = [ pkgs.vpl-gpu-rt ];

      services.avahi = {
        enable = true;
        publish = { enable = true; userServices = true; };
      };
    })
  ]);
}
