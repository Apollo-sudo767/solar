{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.workstation;
in
{
  options.myFeatures.suites.workstation = {
    enable = lib.mkEnableOption "Workstation Suite (Development tools, Terminal, Browsers, Utilities, Audio)";
    minimal = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable minimal / lightweight variants for workstation tools.";
    };

    terminal = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable developer terminal toolchain.";
      };
      ghostty = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Ghostty GPU-accelerated terminal emulator.";
      };
      helix = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Helix modal editor.";
      };
      git = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Git version control system.";
      };
      fastfetch = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Fastfetch system visualizer.";
      };
      nh = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable NH Nix CLI helper.";
      };
      antigravity = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Antigravity AI pair programming agent.";
      };
      direnv = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Direnv automatic environment switching.";
      };
      nix-ld = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable nix-ld dynamic binary execution.";
      };
    };

    browser = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable web browser (Firefox).";
      };
    };

    utilities = {
      filemanager = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable desktop & terminal file managers.";
      };
      bitwarden = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Bitwarden credential manager.";
      };
      social = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable social communication suite (Vesktop & Spotify Player).";
      };
    };

    services = {
      audio = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable PipeWire low-latency audio stack.";
      };
      flatpak = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Flatpak application runtime.";
      };
      xdgPortals = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable XDG Desktop Portals subsystem.";
      };
      udisks2 = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Udisks2 storage auto-mounting daemon.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      core.shell = {
        cli.enable = lib.mkDefault true;
        shell.enable = lib.mkDefault true;
      };

      programs = {
        terminal = lib.mkIf cfg.terminal.enable {
          ghostty.enable = lib.mkIf cfg.terminal.ghostty (lib.mkDefault true);
          helix.enable = lib.mkIf cfg.terminal.helix (lib.mkDefault true);
          git.enable = lib.mkIf cfg.terminal.git (lib.mkDefault true);
          fastfetch.enable = lib.mkIf cfg.terminal.fastfetch (lib.mkDefault true);
          nh.enable = lib.mkIf cfg.terminal.nh (lib.mkDefault true);
          antigravity.enable = lib.mkIf cfg.terminal.antigravity (lib.mkDefault true);
          direnv.enable = lib.mkIf cfg.terminal.direnv (lib.mkDefault true);
          nix-ld.enable = lib.mkIf cfg.terminal.nix-ld (lib.mkDefault true);
        };

        browsers.firefox.enable = lib.mkIf cfg.browser.enable (lib.mkDefault true);

        utilities = {
          filemanager.enable = lib.mkIf cfg.utilities.filemanager (lib.mkDefault true);
          bitwarden.enable = lib.mkIf cfg.utilities.bitwarden (lib.mkDefault true);
          social = lib.mkIf cfg.utilities.social {
            enable = lib.mkDefault true;
            minimal = lib.mkDefault cfg.minimal;
          };
        };
      };

      services = {
        multimedia.audio.enable = lib.mkIf cfg.services.audio (lib.mkDefault true);
        system = {
          flatpak.enable = lib.mkIf cfg.services.flatpak (lib.mkDefault true);
          xdgPortals.enable = lib.mkIf cfg.services.xdgPortals (lib.mkDefault true);
        };
        hardware.udisks2.enable = lib.mkIf cfg.services.udisks2 (lib.mkDefault true);
      };
    };
  };
}
