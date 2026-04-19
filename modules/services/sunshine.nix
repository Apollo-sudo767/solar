{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.sunshine;
in
{
  options.myFeatures.services.sunshine = {
    enable = lib.mkEnableOption "Sunshine: Open-source GameStream host";
    port = lib.mkOption {
      type = lib.types.port;
      default = 47990;
      description = "The port for the Sunshine Web UI";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = false; # Handled manually below using our custom port
    };

    # Logic: Open required ports only if this feature is enabled
    networking.firewall = {
      allowedTCPPorts = [ 47984 47989 48010 cfg.port ];
      allowedUDPPorts = [ 1900 5353 48010 ]; # 1900 is required for UPnP discovery
      allowedUDPPortRanges = [
        { from = 47998; to = 48000; }
        { from = 8000; to = 8010; }
      ];
    };

    boot.kernelModules = [ "uinput" ];
    hardware.uinput.enable = true;
    users.users.apollo.extraGroups = [ "uinput" ];

    environment.systemPackages = with pkgs; [
      sunshine
      vpl-gpu-rt
      miniupnpc # Necessary for Sunshine's internal UPnP logic
    ];

    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
  };
}
