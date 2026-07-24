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
    environment.systemPackages = lib.optional (!pkgs.stdenv.isDarwin) smPkg;

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false && pkgs.stdenv.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".softmaker"
            ];
          });
        };
  };
}
