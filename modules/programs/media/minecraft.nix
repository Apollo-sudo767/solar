{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.minecraft;
  prismCfg = config.myFeatures.programs.media.prism;
  trinityCfg = config.myFeatures.programs.media.trinity;
  flatpakTrinityCfg = config.myFeatures.services.system.flatpak.trinity;
  mcpelauncherCfg = config.myFeatures.programs.media.mcpelauncher;
  flatpakMcpeCfg = config.myFeatures.services.system.flatpak.mcpelauncher;

  javaEnabled = cfg.java.enable || (prismCfg.enable or false);
  bedrockEnabled =
    cfg.bedrock.enable
    || (trinityCfg.enable or false)
    || (flatpakTrinityCfg.enable or false)
    || (mcpelauncherCfg.enable or false)
    || (flatpakMcpeCfg.enable or false);
in
{
  options = {
    myFeatures.programs.media.minecraft = {
      enable = lib.mkEnableOption "Minecraft Suite";
      java = {
        enable = lib.mkEnableOption "Minecraft: Java Edition (Prism Launcher with Java 8/17/21)";
      };
      bedrock = {
        enable = lib.mkEnableOption "Minecraft: Bedrock Edition (Trinity Launcher via Flatpak)";
      };
    };

    # Backwards compatibility and convenience aliases
    myFeatures.programs.media.prism = {
      enable = lib.mkEnableOption "Prism Launcher (alias for minecraft.java)";
    };
    myFeatures.programs.media.trinity = {
      enable = lib.mkEnableOption "Trinity Launcher (alias for minecraft.bedrock)";
    };
    myFeatures.services.system.flatpak.trinity = {
      enable = lib.mkEnableOption "Trinity Launcher (Minecraft Bedrock Edition) via Flatpak";
    };
    myFeatures.programs.media.mcpelauncher = {
      enable = lib.mkEnableOption "Trinity Launcher (legacy alias for minecraft.bedrock)";
    };
    myFeatures.services.system.flatpak.mcpelauncher = {
      enable = lib.mkEnableOption "Trinity Launcher (legacy alias for minecraft.bedrock)";
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

    # Bedrock Edition: Trinity Launcher via Flatpak with nix-flatpak
    (lib.mkIf bedrockEnabled {
      # Ensure Flatpak support is active
      myFeatures.services.system.flatpak.enable = lib.mkDefault true;

      # Declarative repository remote via nix-flatpak
      services.flatpak.remotes = [
        {
          name = "trinity";
          location = "https://github.com/Trinity-LA/Trinity-Launcher/releases/download/flatpak/com.trench.trinity.launcher.flatpakrepo";
        }
      ];

      # Declarative package installation via nix-flatpak
      services.flatpak.packages = [
        {
          appId = "com.trench.trinity.launcher";
          origin = "trinity";
        }
      ];

      # CLI launcher wrappers & Desktop Entry
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "trinity-launcher" ''
          exec flatpak run com.trench.trinity.launcher "$@"
        '')
        (pkgs.writeShellScriptBin "trinity" ''
          exec flatpak run com.trench.trinity.launcher "$@"
        '')
        (pkgs.writeShellScriptBin "mcpelauncher" ''
          exec flatpak run com.trench.trinity.launcher "$@"
        '')
        (pkgs.writeShellScriptBin "mcpelauncher-ui-qt" ''
          exec flatpak run com.trench.trinity.launcher "$@"
        '')
        (pkgs.makeDesktopItem {
          name = "trinity";
          desktopName = "Trinity Launcher";
          genericName = "Minecraft: Bedrock Edition Launcher";
          comment = "Launch Minecraft: Bedrock Edition via Trinity Launcher";
          icon = "trinity";
          exec = "trinity-launcher %U";
          terminal = false;
          type = "Application";
          categories = [
            "Game"
          ];
          startupNotify = true;
        })
        (pkgs.runCommand "trinity-icon" { } ''
          mkdir -p $out/share/icons/hicolor/scalable/apps $out/share/pixmaps
          cp ${../../../assets/icons/trinity.svg} $out/share/icons/hicolor/scalable/apps/trinity.svg
          cp ${../../../assets/icons/trinity.svg} $out/share/pixmaps/trinity.svg
        '')
      ];

      # State preservation for Minecraft Bedrock & Trinity Launcher
      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
        lib.mkIf config.myFeatures.core.system.preservation.enable
          {
            users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
              directories = [
                ".var/app/com.trench.trinity.launcher"
              ];
            });
          };
    })
  ];
}
