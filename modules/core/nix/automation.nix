{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.core.nix.automation;
in
{
  options.myFeatures.core.nix.automation = {
    enable = lib.mkEnableOption "automated GitHub-based flake updates";
    syncHelper = lib.mkEnableOption "local helper script to sync GitHub updates";
  };

  config = lib.mkIf cfg.enable {
    # System-wide helper for the primary user
    home-manager.users.${config.myFeatures.core.system.users.mainUser} = lib.mkIf cfg.syncHelper {
      home.packages = [
        (pkgs.writeShellScriptBin "solar-sync" ''
          set -e
          echo "Checking for Solar system updates from GitHub..."
          git pull origin main
          echo "Flake lock synchronized. Run 'nh os switch' or 'nixos-rebuild' to apply."
        '')
      ];
    };

    # Maintenance notification service
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
  };
}
