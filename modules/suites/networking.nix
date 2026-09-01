{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.networking;
in
{
  options.myFeatures.suites.networking = {
    enable = lib.mkEnableOption "Mesh Networking & Resolved DNS Suite (Tailscale, Resolved)";

    tailscale = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Tailscale WireGuard mesh VPN node.";
      };
    };

    resolved = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Systemd-Resolved DNS resolution daemon.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.services.networking = {
      enable = lib.mkDefault true;
      tailscale.enable = lib.mkIf cfg.tailscale.enable (lib.mkDefault true);
      resolved.enable = lib.mkIf cfg.resolved.enable (lib.mkDefault true);
    };
  };
}
