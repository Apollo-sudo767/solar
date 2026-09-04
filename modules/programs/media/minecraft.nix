{
  config,
  lib,
  pkgs,
  inputs ? null,
  ...
}:

let
  cfg = config.myFeatures.programs.media.minecraft;
  prismCfg = config.myFeatures.programs.media.prism;
  mcpelauncherCfg = config.myFeatures.programs.media.mcpelauncher;
  flatpakMcpeCfg = config.myFeatures.services.system.flatpak.mcpelauncher;
  bedrockOnLinuxAliasCfg = config.myFeatures.programs.media.bedrockOnLinux;

  javaEnabled = cfg.java.enable || (prismCfg.enable or false);

  selectedEdition =
    if cfg.bedrock.platform != null then cfg.bedrock.platform else cfg.bedrock.edition;

  windowsExplicit =
    cfg.bedrock.windows.enable
    || cfg.bedrock.bedrockOnLinux.enable
    || (bedrockOnLinuxAliasCfg.enable or false);

  androidExplicit =
    cfg.bedrock.android.enable
    || cfg.bedrock.mcpelauncher.enable
    || (mcpelauncherCfg.enable or false)
    || (flatpakMcpeCfg.enable or false);

  # Main bedrock enable toggle delegates to selectedEdition unless explicit sub-toggles are set
  windowsEnabled =
    windowsExplicit
    || (
      cfg.bedrock.enable
      && !androidExplicit
      && (selectedEdition == "windows" || selectedEdition == "both")
    )
    || (cfg.bedrock.enable && selectedEdition == "both");

  androidEnabled =
    androidExplicit
    || (
      cfg.bedrock.enable
      && !windowsExplicit
      && (selectedEdition == "android" || selectedEdition == "both")
    )
    || (cfg.bedrock.enable && selectedEdition == "both");

  bedrockOnLinuxFlakePkg =
    if
      inputs != null
      && inputs ? bedrock-on-linux
      && inputs.bedrock-on-linux ? packages
      && inputs.bedrock-on-linux.packages ? ${pkgs.stdenv.hostPlatform.system}
    then
      inputs.bedrock-on-linux.packages.${pkgs.stdenv.hostPlatform.system}.default
    else
      null;

  bedrockOnLinuxPkg = bedrockOnLinuxFlakePkg;

  windowsPackage =
    if cfg.bedrock.windows.package != null then
      cfg.bedrock.windows.package
    else if cfg.bedrock.bedrockOnLinux.package != null then
      cfg.bedrock.bedrockOnLinux.package
    else
      bedrockOnLinuxPkg;
in
{
  options = {
    myFeatures.programs.media.minecraft = {
      enable = lib.mkEnableOption "Minecraft Suite";
      java = {
        enable = lib.mkEnableOption "Minecraft: Java Edition (Prism Launcher with Java 8/17/21)";
      };
      bedrock = {
        enable = lib.mkEnableOption "Minecraft: Bedrock Edition";

        edition = lib.mkOption {
          type = lib.types.enum [
            "windows"
            "android"
            "both"
          ];
          default = "windows";
          description = "Minecraft Bedrock Edition toggle: 'windows' (BedrockOnLinux - Windows GDK) or 'android' (MCPELauncher via Flatpak).";
        };

        platform = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.enum [
              "windows"
              "android"
              "both"
            ]
          );
          default = null;
          description = "Convenience alias for minecraft.bedrock.edition.";
        };

        windows = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Minecraft Bedrock for Windows (BedrockOnLinux).";
          };
          package = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = bedrockOnLinuxPkg;
            description = "BedrockOnLinux package to install.";
          };
        };

        android = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Minecraft Bedrock for Android (MCPELauncher via Flatpak).";
          };
        };

        bedrockOnLinux = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable BedrockOnLinux (alias for minecraft.bedrock.windows.enable).";
          };
          package = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = null;
            description = "BedrockOnLinux package to install (alias for minecraft.bedrock.windows.package).";
          };
        };

        mcpelauncher = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable MCPELauncher (alias for minecraft.bedrock.android.enable).";
          };
        };
      };
    };

    # Backwards compatibility and convenience aliases
    myFeatures.programs.media.prism = {
      enable = lib.mkEnableOption "Prism Launcher (alias for minecraft.java)";
    };
    myFeatures.programs.media.bedrockOnLinux = {
      enable = lib.mkEnableOption "BedrockOnLinux (Minecraft Bedrock for Windows, alias for minecraft.bedrock.windows)";
    };
    myFeatures.programs.media.mcpelauncher = {
      enable = lib.mkEnableOption "MCPELauncher (alias for minecraft.bedrock.android)";
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

    # Bedrock Edition (Windows): BedrockOnLinux
    (lib.mkIf windowsEnabled {
      environment.systemPackages = lib.optionals (windowsPackage != null) [
        windowsPackage
        (pkgs.writeShellScriptBin "bedrockonlinux" ''
          exec ${lib.getExe windowsPackage} "$@"
        '')
      ];

      # State preservation for BedrockOnLinux
      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
        lib.mkIf config.myFeatures.core.system.preservation.enable
          {
            users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
              directories = [
                ".local/share/bedrock-on-linux"
                ".config/bedrock-on-linux"
              ];
            });
          };
    })

    # Bedrock Edition (Android): MCPELauncher via Flatpak with nix-flatpak
    (lib.mkIf androidEnabled {
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
