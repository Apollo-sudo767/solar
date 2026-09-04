{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.gaming;
in
{
  options.myFeatures.suites.gaming = {
    enable = lib.mkEnableOption "Gaming Suite (Steam, GameScope, Controllers, Audio & Communication)";

    steam = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable native Steam gaming platform.";
      };
      protonInstaller = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable ProtonUp-Qt compatibility tool manager.";
      };
      gamescope = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable GameScope micro-compositor wrapper.";
      };
    };

    voip = {
      mumble = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Mumble low-latency VoIP client with Wayland push-to-talk.";
      };
    };

    minecraft = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Minecraft gaming suite.";
      };
      java = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Minecraft: Java Edition (Prism Launcher).";
        };
      };
      bedrock = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Minecraft: Bedrock Edition.";
        };
        edition = lib.mkOption {
          type = lib.types.enum [
            "windows"
            "android"
            "both"
          ];
          default = "windows";
          description = "Minecraft Bedrock Edition toggle: 'windows' (BedrockOnLinux - Windows GDK) or 'android' (MCPELauncher via Flatpak).";
        };
        windows = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Minecraft Bedrock for Windows (BedrockOnLinux).";
        };
        android = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Minecraft Bedrock for Android (MCPELauncher via Flatpak).";
        };
        bedrockOnLinux = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable BedrockOnLinux (Minecraft Bedrock for Windows).";
        };
      };
    };

    games = {
      tf2 = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Team Fortress 2 competitive suite.";
      };
      minecraft = {
        java = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Minecraft: Java Edition (Prism Launcher).";
        };
        bedrock = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Minecraft: Bedrock Edition.";
        };
        windows = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Minecraft Bedrock for Windows (BedrockOnLinux).";
        };
        android = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Minecraft Bedrock for Android (MCPELauncher via Flatpak).";
        };
        bedrockOnLinux = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable BedrockOnLinux (Minecraft Bedrock for Windows).";
        };
      };
      roblox = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Roblox (Sober via Flatpak).";
      };

      # Convenience / legacy aliases
      prism = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Prism Minecraft launcher (alias for games.minecraft.java).";
      };
      bedrockOnLinux = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable BedrockOnLinux (alias for minecraft.bedrock.windows).";
      };
      mcpelauncher = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable MCPELauncher (alias for minecraft.bedrock.android).";
      };
      sober = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Sober (alias for games.roblox).";
      };
    };

    controllers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable gamepad controller subsystem.";
      };
      xbox = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Xbox One & Series controller drivers and xpadneo.";
      };
      nintendo = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Nintendo Switch Pro controller support.";
      };
      playstation = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable PlayStation DualSense controller drivers.";
      };
    };

    social = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable social communication suite (Vesktop & Spotify Player).";
      };
      minimal = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use minimal/lightweight social suite clients.";
      };
    };

    audio = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable PipeWire low-latency gaming audio.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      programs.media = {
        gaming.enable = lib.mkIf cfg.steam.enable (lib.mkDefault true);
        steam = {
          protonInstaller.enable = lib.mkIf (cfg.steam.enable && cfg.steam.protonInstaller) (
            lib.mkDefault true
          );
          gamescope.enable = lib.mkIf (cfg.steam.enable && cfg.steam.gamescope) (lib.mkDefault true);
        };
        mumble.enable = lib.mkIf cfg.voip.mumble (lib.mkDefault true);
        tf2.enable = lib.mkIf cfg.games.tf2 (lib.mkDefault true);
        minecraft = {
          enable = lib.mkIf cfg.minecraft.enable (lib.mkDefault true);
          java.enable = lib.mkIf (cfg.minecraft.java.enable || cfg.games.minecraft.java || cfg.games.prism) (
            lib.mkDefault true
          );
          bedrock = {
            enable = lib.mkIf (
              cfg.minecraft.bedrock.enable
              || cfg.games.minecraft.bedrock
              || cfg.minecraft.bedrock.windows
              || cfg.minecraft.bedrock.android
              || cfg.minecraft.bedrock.bedrockOnLinux
              || cfg.games.minecraft.windows
              || cfg.games.minecraft.android
              || cfg.games.minecraft.bedrockOnLinux
              || cfg.games.bedrockOnLinux
              || cfg.games.mcpelauncher
            ) (lib.mkDefault true);
            edition = lib.mkIf (cfg.minecraft.bedrock.enable || cfg.games.minecraft.bedrock) (
              lib.mkDefault cfg.minecraft.bedrock.edition
            );
            windows.enable = lib.mkIf (
              cfg.minecraft.bedrock.windows
              || cfg.minecraft.bedrock.bedrockOnLinux
              || cfg.games.minecraft.windows
              || cfg.games.minecraft.bedrockOnLinux
              || cfg.games.bedrockOnLinux
            ) (lib.mkDefault true);
            android.enable = lib.mkIf (
              cfg.minecraft.bedrock.android || cfg.games.minecraft.android || cfg.games.mcpelauncher
            ) (lib.mkDefault true);
          };
        };
        roblox.enable = lib.mkIf (cfg.games.roblox || cfg.games.sober) (lib.mkDefault true);
      };

      hardware.input.controllers = lib.mkIf cfg.controllers.enable {
        enable = lib.mkDefault true;
        xbox = lib.mkIf cfg.controllers.xbox (lib.mkDefault true);
        nintendo = lib.mkIf cfg.controllers.nintendo (lib.mkDefault true);
        playstation = lib.mkIf cfg.controllers.playstation (lib.mkDefault true);
      };

      programs.utilities.social = lib.mkIf cfg.social.enable {
        enable = lib.mkDefault true;
        minimal = lib.mkDefault cfg.social.minimal;
      };

      services.multimedia.audio.enable = lib.mkIf cfg.audio.enable (lib.mkDefault true);
    };
  };
}
