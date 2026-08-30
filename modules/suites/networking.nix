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
  };

  config = lib.mkIf cfg.enable {
    myFeatures.services.networking = {
      enable = lib.mkDefault true;
      tailscale.enable = lib.mkDefault true;
      resolved.enable = lib.mkDefault true;
    };
  };
}
