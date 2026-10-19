{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.minimal;
in
{
  options.myFeatures.suites.minimal = {
    enable = lib.mkEnableOption "Minimal Desktop & Tool Suite (Lightweight Desktop, Minimal Tools & TUI Clients)";

    social.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable minimal social suite (Vesktop + Spotify Player).";
    };

    terminal.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable essential terminal and developer tools (Helix, Ghostty, Git, NH, Fastfetch, Direnv, Nix-LD).";
    };

    office.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable lightweight modular office tools (AbiWord, Gnumeric, PDFArranger, Evince).";
    };

    browser.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable default browser (Firefox).";
    };

    media.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable lightweight media playback tools.";
    };

    utilities.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable core utilities (Bitwarden, File Manager).";
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
          ghostty.enable = lib.mkDefault true;
          helix.enable = lib.mkDefault true;
          git.enable = lib.mkDefault true;
          fastfetch.enable = lib.mkDefault true;
          nh.enable = lib.mkDefault true;
          direnv.enable = lib.mkDefault true;
          nix-ld.enable = lib.mkDefault true;
        };

        browsers.firefox.enable = lib.mkIf cfg.browser.enable (lib.mkDefault true);

        office.lightweight.enable = lib.mkIf cfg.office.enable (lib.mkDefault true);

        media.media.enable = lib.mkIf cfg.media.enable (lib.mkDefault true);

        utilities = {
          filemanager.enable = lib.mkIf cfg.utilities.enable (lib.mkDefault true);
          bitwarden.enable = lib.mkIf cfg.utilities.enable (lib.mkDefault true);
          social = lib.mkIf cfg.social.enable {
            enable = lib.mkDefault true;
            minimal = lib.mkDefault true;
          };
        };
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        system = {
          flatpak.enable = lib.mkDefault true;
          xdgPortals.enable = lib.mkDefault true;
        };
        hardware.udisks2.enable = lib.mkDefault true;
      };
    };
  };
}
