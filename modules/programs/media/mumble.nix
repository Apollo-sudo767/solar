{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.mumble;
in
{
  options.myFeatures.programs.media.mumble = {
    enable = lib.mkEnableOption "Mumble VoIP client";

    overlay = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Mumble in-game overlay support";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.mumble
    ]
    ++ lib.optional (cfg.overlay.enable && pkgs.stdenv.hostPlatform.isLinux) pkgs.mumble_overlay;

    # On Linux, grant access to input group so Mumble can capture Push-to-Talk
    # global shortcuts under Wayland (Niri/Sway/Hyprland) via evdev when unfocused.
    users.users = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
      lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
        extraGroups = [ "input" ];
      })
    );

    # Impermanence preservation for Mumble certificates, server favorites, and audio configs
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.hostPlatform.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/Mumble"
              ".local/share/Mumble"
              ".local/share/data/Mumble"
            ];
          });
        };
  };
}
