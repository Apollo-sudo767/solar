# templates/feature.nix
# ============================================================================
# Dendritic Feature Module Template (`modules/<category>/<subcategory>/<name>.nix`)
# ============================================================================
# How the Dendritic Autoscanner (`modules/default.nix`) handles this file:
# 1. Any `.nix` file placed under `modules/` (outside `modules/hosts/`) is
#    automatically imported—no manual `imports = [ ... ];` list is needed.
# 2. The option path under `options.myFeatures` MUST mirror the directory path:
#    e.g., `modules/programs/terminal/mytool.nix` -> `myFeatures.programs.terminal.mytool`.
# 3. Platform Filtering:
#    - Linux-only modules: omit `isDarwin` and `isTotal` from the function arguments.
#      They will be automatically skipped when building macOS (`darwinConfigurations`).
#    - Cross-platform modules: include `isDarwin` (or `isTotal`) in the function
#      arguments so the macOS evaluator imports the module, and guard Linux-only
#      NixOS options (like `systemd`, `preservation`, `services.*`) inside
#      `lib.optionalAttrs (!isDarwin) { ... }`.
{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  # Option path matches the directory hierarchy:
  # modules/programs/terminal/mytool.nix -> config.myFeatures.programs.terminal.mytool
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

  # 2. IMPLEMENTATION (Only applied when `enable = true;`)
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # A. Cross-Platform Configuration (Evaluated on both NixOS and nix-darwin)
      {
        environment.systemPackages = [ cfg.package ];

        # Apply Home Manager dotfiles across all configured users on the host
        home-manager.sharedModules = [
          {
            xdg.configFile."mytool/config.toml".text = ''
              enabled = true
              ${cfg.extraConfig}
            '';
          }
        ];
      }

      # B. Linux-Only Configuration (Erased from the attribute set on macOS)
      (lib.optionalAttrs (!isDarwin) {
        # Persist application state across reboots when ephemeral root (`usePersistence`) is active
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
