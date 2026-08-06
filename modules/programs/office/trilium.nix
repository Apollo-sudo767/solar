{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.trilium;
in
{
  options.myFeatures.programs.office.trilium = {
    enable = lib.mkEnableOption "Trilium Notes desktop application";
    gui = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install the Trilium Notes desktop client application.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optional cfg.gui pkgs.trilium-desktop;

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !isDarwin)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [ ".config/trilium-notes" ];
          });
        };
  };
}
