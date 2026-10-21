# modules/suites/gaming.nix
# ============================================================================
# Gaming Composite Suite
# ============================================================================
# High-level gaming bundle configuring:
# - Steam + ProtonUp-Qt / ProtonPlus + Gamescope micro-compositor
# - Low-latency Mumble VoIP and Team Fortress 2 competitive tools
# - Minecraft (Java Edition via Prism Launcher, Bedrock Edition for Windows/Android)
# - Roblox (Sober via Flatpak)
# - Gamepad controller drivers (Xbox, Nintendo, PlayStation)
# - Social communication clients (Vesktop + Spotify Player) and PipeWire audio
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
        description = "Enable ProtonUp-Qt / ProtonPlus compatibility tool manager.";
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
          description = "Minecraft Bedrock Edition target: 'windows' (BedrockOnLinux - Windows GDK), 'android' (MCPELauncher via Flatpak), or 'both'.";
        };
      };
    };

    games = {
      tf2 = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Team Fortress 2 competitive suite.";
      };
      roblox = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Roblox (Sober via Flatpak).";
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
        steam = {
          enable = lib.mkIf cfg.steam.enable (lib.mkDefault true);
          protonInstaller.enable = lib.mkIf (cfg.steam.enable && cfg.steam.protonInstaller) (
            lib.mkDefault true
          );
          gamescope.enable = lib.mkIf (cfg.steam.enable && cfg.steam.gamescope) (lib.mkDefault true);
        };
        mumble.enable = lib.mkIf cfg.voip.mumble (lib.mkDefault true);
        tf2.enable = lib.mkIf cfg.games.tf2 (lib.mkDefault true);
        minecraft = {
          enable = lib.mkIf cfg.minecraft.enable (lib.mkDefault true);
          java.enable = lib.mkIf cfg.minecraft.java.enable (lib.mkDefault true);
          bedrock = {
            enable = lib.mkIf cfg.minecraft.bedrock.enable (lib.mkDefault true);
            edition = lib.mkIf cfg.minecraft.bedrock.enable (lib.mkDefault cfg.minecraft.bedrock.edition);
            windows.enable = lib.mkIf (
              cfg.minecraft.bedrock.enable
              && (cfg.minecraft.bedrock.edition == "windows" || cfg.minecraft.bedrock.edition == "both")
            ) (lib.mkDefault true);
            android.enable = lib.mkIf (
              cfg.minecraft.bedrock.enable
              && (cfg.minecraft.bedrock.edition == "android" || cfg.minecraft.bedrock.edition == "both")
            ) (lib.mkDefault true);
          };
        };
        roblox.enable = lib.mkIf cfg.games.roblox (lib.mkDefault true);
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
