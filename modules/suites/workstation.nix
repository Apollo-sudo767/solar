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
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      core.shell = {
        cli.enable = lib.mkDefault true;
        shell.enable = lib.mkDefault true;
      };

      programs = {
        terminal = {
          ghostty.enable = lib.mkDefault true;
          helix.enable = lib.mkDefault true;
          git.enable = lib.mkDefault true;
          fastfetch.enable = lib.mkDefault true;
          nh.enable = lib.mkDefault true;
          antigravity.enable = lib.mkDefault true;
          direnv.enable = lib.mkDefault true;
          nix-ld.enable = lib.mkDefault true;
        };

        browsers.firefox.enable = lib.mkDefault true;

        utilities = {
          filemanager.enable = lib.mkDefault true;
          bitwarden.enable = lib.mkDefault true;
          social.enable = lib.mkDefault true;
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
