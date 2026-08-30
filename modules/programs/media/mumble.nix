{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.mumble;

  wrappedMumble = pkgs.symlinkJoin {
    name = "mumble-wrapped";
    paths = [ pkgs.mumble ];
    postBuild = ''
      rm $out/bin/mumble
      cat <<'EOF' > $out/bin/mumble
      #!/bin/sh
      if [ "$1" = "%u" ] || [ "$1" = "%U" ]; then
        shift
      fi
      export LD_LIBRARY_PATH="${pkgs.libpulseaudio}/lib"
      if [ -z "$MUMBLE_SYSTEMD_SCOPED" ] && [ -n "$XDG_RUNTIME_DIR" ] && command -v systemd-run >/dev/null 2>&1; then
        export MUMBLE_SYSTEMD_SCOPED=1
        exec systemd-run --user --scope --collect --unit="app-mumble-$$-$(date +%s%N)" -- ${pkgs.mumble}/bin/mumble --skip-settings-backup-prompt "$@"
      fi
      exec ${pkgs.mumble}/bin/mumble --skip-settings-backup-prompt "$@"
      EOF
      chmod +x $out/bin/mumble
    '';
    meta = pkgs.mumble.meta // {
      mainProgram = "mumble";
    };
  };
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
      wrappedMumble
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
