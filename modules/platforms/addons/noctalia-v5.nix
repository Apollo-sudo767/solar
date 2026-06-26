{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.noctalia-v5;
  inherit (config.myFeatures.core.system.users) usernames;
in
{
  options.myFeatures.platforms.addons.noctalia-v5.enable =
    lib.mkEnableOption "Noctalia Shell v5 (Wayland Shell)";

  config = lib.mkIf cfg.enable {
    # Required services for Noctalia's status modules
    services.upower.enable = lib.mkDefault true;

    nix.settings = {
      substituters = [ "https://noctalia.cachix.org" ];
      trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
    };

    # Disable standalone alternatives to let Noctalia handle them
    myFeatures.platforms.addons = {
      waybar.enable = lib.mkForce false;
      fuzzel.enable = lib.mkForce false;
      swaync.enable = lib.mkForce false;
      swaybg.enable = lib.mkForce false;
      idle.enable = lib.mkForce false;
    };

    home-manager.users = lib.genAttrs usernames (name: { config, ... }: {
      imports = [ inputs.noctalia-v5.homeModules.default ];

      programs.noctalia = {
        enable = true;
        package = pkgs.symlinkJoin {
          name = "noctalia-wrapped";
          paths = [ inputs.noctalia-v5.packages.${pkgs.stdenv.hostPlatform.system}.default ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/noctalia \
              --prefix XDG_DATA_DIRS : '/home/${name}/.local/share:/home/${name}/Desktop:/home/${name}/Desktops'
          '';
          meta.mainProgram = "noctalia";
        };
      };

      home.file."Desktop/applications" = {
        source = config.lib.file.mkOutOfStoreSymlink "/home/${name}/Desktop";
      };
      home.file."Desktop/.hidden".text = "applications\n";

      home.file."Desktops/applications" = {
        source = config.lib.file.mkOutOfStoreSymlink "/home/${name}/Desktops";
      };
      home.file."Desktops/.hidden".text = "applications\n";
    });
  };
}
