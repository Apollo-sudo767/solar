{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.minecraft;
  prismCfg = config.myFeatures.programs.media.prism;
  mcpelauncherCfg = config.myFeatures.programs.media.mcpelauncher;
  flatpakMcpeCfg = config.myFeatures.services.system.flatpak.mcpelauncher;

  javaEnabled = cfg.java.enable || (prismCfg.enable or false);
  bedrockEnabled =
    cfg.bedrock.enable || (mcpelauncherCfg.enable or false) || (flatpakMcpeCfg.enable or false);
in
{
  options = {
    myFeatures.programs.media.minecraft = {
      enable = lib.mkEnableOption "Minecraft Suite";
      java = {
        enable = lib.mkEnableOption "Minecraft: Java Edition (Prism Launcher with Java 8/17/21)";
      };
      bedrock = {
        enable = lib.mkEnableOption "Minecraft: Bedrock Edition (MCPELauncher via Flatpak)";
      };
    };

    # Backwards compatibility and convenience aliases
    myFeatures.programs.media.prism = {
      enable = lib.mkEnableOption "Prism Launcher (alias for minecraft.java)";
    };
    myFeatures.programs.media.mcpelauncher = {
      enable = lib.mkEnableOption "MCPELauncher (alias for minecraft.bedrock)";
    };
    myFeatures.services.system.flatpak.mcpelauncher = {
      enable = lib.mkEnableOption "MCPELauncher (Minecraft Bedrock Edition) via Flatpak";
    };
  };

  config = lib.mkMerge [
    # Top-level minecraft.enable defaults to enabling Java Edition
    (lib.mkIf cfg.enable {
      myFeatures.programs.media.minecraft.java.enable = lib.mkDefault true;
    })

    # Java Edition: Prism Launcher with bundled JDKs
    (lib.mkIf javaEnabled {
      environment.systemPackages = [
        # This overrides Prism's internal wrapper to expose all necessary JDKs
        (pkgs.prismlauncher.override {
          jdks = with pkgs; [
            temurin-bin-21 # For modern Minecraft (1.20.5+)
            temurin-bin-17 # For intermediate versions (1.17 - 1.20.4)
            openjdk8 # For legacy and classic modpacks (1.16.5 and below)
          ];
        })
      ];

      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
        lib.mkIf config.myFeatures.core.system.preservation.enable
          {
            users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
              directories = [
                ".local/share/PrismLauncher"
                ".config/PrismLauncher"
              ];
            });
          };
    })

    # Bedrock Edition: MCPELauncher via Flatpak with nix-flatpak
    (lib.mkIf bedrockEnabled {
      # Ensure Flatpak support is active
      myFeatures.services.system.flatpak.enable = lib.mkDefault true;

      # Declarative package installation via nix-flatpak
      services.flatpak.packages = [
        "io.mrarm.mcpelauncher"
      ];

      # CLI launcher wrappers
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "mcpelauncher" ''
          exec flatpak run io.mrarm.mcpelauncher "$@"
        '')
        (pkgs.writeShellScriptBin "mcpelauncher-ui-qt" ''
          exec flatpak run io.mrarm.mcpelauncher "$@"
        '')
      ];

      # State preservation for Minecraft Bedrock & MCPELauncher
      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
        lib.mkIf config.myFeatures.core.system.preservation.enable
          {
            users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
              directories = [
                ".var/app/io.mrarm.mcpelauncher"
              ];
            });
          };
    })
  ];
}
