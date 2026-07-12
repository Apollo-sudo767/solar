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
      waybar.enable = lib.mkForce false;
      fuzzel.enable = lib.mkForce false;
      swaync.enable = lib.mkForce false;
      swaybg.enable = lib.mkForce false;
      idle.enable = lib.mkForce false;
    };

    systemd.user.services.noctalia-lock-on-suspend =
      lib.mkIf config.myFeatures.platforms.desktops.niri.enable
        {
          description = "Lock Noctalia Shell on Suspend";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.swayidle}/bin/swayidle -w before-sleep 'qs -c noctalia-shell ipc call lockScreen lock'";
            Restart = "always";
          };
        };

    home-manager.users = lib.genAttrs usernames (
      name: { config, ... }: {
        imports = [ inputs.noctalia.homeModules.default ];

        programs.noctalia-shell = {
          enable = true;
          package = pkgs.symlinkJoin {
            name = "noctalia-shell-wrapped";
            paths = [ pkgs.noctalia-shell ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/noctalia-shell \
                --prefix XDG_DATA_DIRS : '/home/${name}/.local/share:/home/${name}/Desktop:/home/${name}/Desktops'
            '';
            meta.mainProgram = "noctalia-shell";
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
      }
    );
  };
}
