# templates/feature.nix
# Template for creating a new dendritic feature module under modules/programs/, modules/services/, etc.
{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  # The path in options matches the directory structure:
  # e.g. modules/programs/terminal/mytool.nix -> myFeatures.programs.terminal.mytool
  cfg = config.myFeatures.programs.terminal.mytool;
in
{
  # 1. OPTIONS (Dendritic Hierarchy)
  options.myFeatures.programs.terminal.mytool = {
    enable = lib.mkEnableOption "MyTool CLI application";
    package = lib.mkPackageOption pkgs "mytool" { };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra configuration lines appended to mytool config.";
    };
  };

  # 2. CONFIGURATION
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Common Configuration (Linux & macOS Darwin)
      {
        environment.systemPackages = [ cfg.package ];

        # Universal Home Manager dotfiles across all declared users
        home-manager.sharedModules = [
          {
            xdg.configFile."mytool/config.toml".text = ''
              enabled = true
              ${cfg.extraConfig}
            '';
          }
        ];
      }

      # Linux-Only Configuration (Guarded with optionalAttrs to prevent Darwin eval errors)
      (lib.optionalAttrs (!isDarwin) {
        # Ephemeral wipe-on-boot state preservation
        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories = [
                  ".config/mytool"
                  ".local/share/mytool"
                ];
              });
            };
      })
    ]
  );
}
