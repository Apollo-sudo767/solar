{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.noctalia-shell;
  inherit (config.myFeatures.core.system.users) usernames;
  stylixEnabled = config.myFeatures.platforms.styling.stylix.enable;
  iconFile = ../../../assets/icons/Apollo.jpg;
in
{
  options.myFeatures.platforms.addons.noctalia-shell.enable =
    lib.mkEnableOption "Noctalia Shell (Wayland Shell)";

  config = lib.mkIf cfg.enable {
    # Required services for Noctalia's status modules
    services.upower.enable = lib.mkDefault true;

    nix.settings = {
      substituters = [ "https://noctalia.cachix.org" ];
      trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
    };

    # Disable standalone alternatives to let Noctalia handle them
    myFeatures.platforms.addons = {
      swaybg.enable = lib.mkForce false;
      idle.enable = lib.mkForce false;
    };

    home-manager.users = lib.genAttrs usernames (name: {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia-shell = {
        enable = true;
        package = pkgs.noctalia-shell;
      };
    });
  };
}
