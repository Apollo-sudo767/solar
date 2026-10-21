# modules/core/nix/automation.nix
# ============================================================================
# Flake Update Helper & Weekly Notification Service
# ============================================================================
# When `myFeatures.core.nix.automation.enable = true;` is set:
# 1. Installs the `solar-sync` CLI script into the primary user's Home Manager
#    profile to pull the latest `main` branch from GitHub.
# 2. On Linux desktops, configures a weekly systemd user timer (`Mon 09:00`)
#    that sends a desktop notification reminding the user to sync updates.
{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.nix.automation;
  userCfg = config.myFeatures.core.system.users;
in
{
  options.myFeatures.core.nix.automation = {
    enable = lib.mkEnableOption "automated GitHub-based flake updates";
    syncHelper = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the `solar-sync` helper script and weekly desktop update reminder.";
    };
  };

  config = lib.mkIf (cfg.enable && isTotal) (
    lib.mkMerge [
      {
        # Install `solar-sync` helper script for the primary user
        home-manager.users.${userCfg.mainUser} = lib.mkIf cfg.syncHelper {
          home.packages = [
            (pkgs.writeShellScriptBin "solar-sync" ''
              set -e
              echo "Checking for Solar system updates from GitHub..."
              git pull origin main
              echo "Flake lock synchronized. Run 'nh os switch' or 'nixos-rebuild' to apply."
            '')
          ];
        };
      }

      # Weekly maintenance desktop notification service (Linux-only)
      (lib.optionalAttrs (!isDarwin) {
        systemd.user.services."solar-update-notify" = lib.mkIf cfg.syncHelper {
          description = "Notify user of weekly flake update availability";
          serviceConfig.PassEnvironment = "DISPLAY";
          script = ''
            ${pkgs.libnotify}/bin/notify-send -u normal \
              "Solar System" \
              "Weekly flake update is available. Run 'solar-sync' to pull changes."
          '';
          startAt = "Mon 09:00";
        };
      })
    ]
  );
}
