# modules/platforms/addons/noctalia-v5.nix
#
# Configures Noctalia Shell v5 (Wayland shell), Cachix binary cache,
# user profile icon provisioning, and state preservation on NixOS.
{
  config,
  lib,
  inputs,
  pkgs,
  isStable ? false,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.noctalia-v5;
  inherit (config.myFeatures.core.system.users) usernames;
in
{
  imports = [
    inputs.noctalia-v5.nixosModules.default
  ];

  options.myFeatures.platforms.addons.noctalia-v5.enable =
    lib.mkEnableOption "Noctalia Shell v5 (Wayland Shell)";

  config = lib.mkIf cfg.enable {
    # Enable Noctalia's NixOS module & recommended system services
    # (NetworkManager, Bluetooth, UPower, and power-profiles-daemon when not overridden).
    # We set `package = null` at the system level because Home Manager installs the
    # wrapped binary with user XDG_DATA_DIRS below.
    programs.noctalia = {
      enable = true;
      package = null;
      recommendedServices.enable = true;
    };

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
          description = "Lock Noctalia on Suspend";
          wantedBy = [
            "graphical-session.target"
            "niri-session.target"
          ];
          partOf = [
            "graphical-session.target"
            "niri-session.target"
          ];
          after = [
            "graphical-session.target"
            "niri-session.target"
          ];
          path = [
            pkgs.swayidle
            pkgs.bash
          ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.swayidle}/bin/swayidle -w before-sleep '${pkgs.writeShellScript "noctalia-v5-lock" ''
              if command -v noctalia >/dev/null 2>&1; then
                noctalia msg session lock
              fi
            ''}'";
            Restart = "always";
            Environment = [
              "PATH=/etc/profiles/per-user/%u/bin:%h/.nix-profile/bin:/run/current-system/sw/bin"
            ];
          };
        };

    home-manager.users = lib.genAttrs usernames (
      name: { config, ... }: {
        imports = lib.optional isStable inputs.noctalia-v5.homeModules.default;

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
          settings = lib.optionalAttrs (name == "apollo") {
            avatar_path = "${../../../assets/icons/Apollo.jpg}";
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
