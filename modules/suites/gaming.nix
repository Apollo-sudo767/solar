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
          description = "Enable Minecraft: Bedrock Edition (Trinity Launcher via Flatpak).";
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
      trinity = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Trinity Launcher (alias for games.minecraft.bedrock).";
      };
      mcpelauncher = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Trinity Launcher (legacy alias for games.minecraft.bedrock).";
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
          java.enable = lib.mkIf (cfg.games.minecraft.java || cfg.games.prism) (lib.mkDefault true);
          bedrock.enable = lib.mkIf (
            cfg.games.minecraft.bedrock || cfg.games.trinity || cfg.games.mcpelauncher
          ) (lib.mkDefault true);
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
