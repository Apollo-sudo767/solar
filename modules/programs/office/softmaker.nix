# modules/programs/office/softmaker.nix
# ============================================================================
# SoftMaker FreeOffice / Office Suite
# ============================================================================
# Installs SoftMaker FreeOffice (`freeoffice`) or SoftMaker Office (`office`)
# on Linux, registers default MIME associations for enabled components
# (TextMaker, PlanMaker, Presentations), and preserves `~/.softmaker`.
{
  config,
  lib,
  pkgs,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.softmaker;
  smPkg = if cfg.variant == "freeoffice" then pkgs.freeoffice else pkgs.softmaker-office;
  prefix = if cfg.variant == "freeoffice" then "freeoffice" else "softmaker";
in
{
  options.myFeatures.programs.office.softmaker = {
    enable = lib.mkEnableOption "SoftMaker FreeOffice / Office Suite";

    variant = lib.mkOption {
      type = lib.types.enum [
        "freeoffice"
        "office"
      ];
      default = "freeoffice";
      description = "SoftMaker package variant: 'freeoffice' (Free edition) or 'office' (Professional edition).";
    };

    components = {
      textmaker = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "TextMaker word processor.";
      };
      planmaker = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "PlanMaker spreadsheet editor.";
      };
      presentations = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Presentations slide deck tool.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optional (!pkgs.stdenv.hostPlatform.isDarwin) smPkg;

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xdg.mimeApps = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
        enable = true;
        defaultApplications = {
          "application/msword" = lib.mkIf cfg.components.textmaker [ "${prefix}-textmaker.desktop" ];
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
            lib.mkIf cfg.components.textmaker
              [ "${prefix}-textmaker.desktop" ];
          "application/vnd.ms-excel" = lib.mkIf cfg.components.planmaker [ "${prefix}-planmaker.desktop" ];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
            lib.mkIf cfg.components.planmaker
              [ "${prefix}-planmaker.desktop" ];
          "application/vnd.ms-powerpoint" = lib.mkIf cfg.components.presentations [
            "${prefix}-presentations.desktop"
          ];
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
            lib.mkIf cfg.components.presentations
              [ "${prefix}-presentations.desktop" ];
        };
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf
        (config.myFeatures.core.system.preservation.enable or false && pkgs.stdenv.hostPlatform.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".softmaker"
            ];
          });
        };
  };
}
