{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  options.myFeatures.platforms.desktops.niri = {
    enable = lib.mkEnableOption "Niri Window Manager";
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Niri settings";
    };
    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra Niri configuration in KDL format";
    };
  };

  # Shield everything
  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    nix.settings = {
      substituters = [ "https://niri.cachix.org" ];
      trusted-public-keys = [ "niri.cachix.org-1:Wv0Om607Z5X0CQy+/J67p4H6at0S0p6+H46M06+mErc=" ];
    };

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      imports = [ inputs.niri.homeModules.niri ];
      programs.niri.settings = cfg.settings;
    });

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
