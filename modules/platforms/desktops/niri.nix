{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  options.myFeatures.platforms.desktops.niri.enable = lib.mkEnableOption "Niri Window Manager";

  # Shield everything
  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    nix.settings = {
      substituters = [ "https://niri.cachix.org" ];
      trusted-public-keys = [ "niri.cachix.org-1:Wv0Om607Z5X0CQy+/J67p4H6at0S0p6+H46M06+mErc=" ];
    };

    environment.systemPackages =
      with pkgs;
      [
        xwayland-satellite
        networkmanagerapplet
        thunar
        awww
        brightnessctl
      ]
      ++ lib.optionals (!config.myFeatures.platforms.addons.noctalia-shell.enable) [
        fuzzel
        mako
        swaynotificationcenter
        swaybg
        swayidle
        swalock
      ];
  };
}
