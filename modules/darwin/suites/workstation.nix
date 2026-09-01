{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.suites.darwinWorkstation;
in
{
  options.myFeatures.suites.darwinWorkstation = {
    enable = lib.mkEnableOption "Darwin (macOS) Workstation Suite";

    homebrew = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable declarative Homebrew bundle integration.";
      };
    };

    terminal = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable macOS terminal and developer tools.";
      };
      helix = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Helix modal editor.";
      };
      fastfetch = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Fastfetch system visualizer.";
      };
      antigravity = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Antigravity AI pair programmer.";
      };
      direnv = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Direnv automatic environment switcher.";
      };
    };

    utilities = {
      filemanager = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable file manager.";
      };
    };

    office = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable AP-Office suite on Darwin.";
      };
    };
  };

  config = lib.mkIf (cfg.enable && isDarwin) {
    myFeatures = {
      core.shell = {
        cli.enable = lib.mkDefault true;
        shell.enable = lib.mkDefault true;
      };

      darwin.system = {
        core.enable = lib.mkDefault true;
        homebrew.enable = lib.mkIf cfg.homebrew.enable (lib.mkDefault true);
      };

      programs = {
        terminal = lib.mkIf cfg.terminal.enable {
          helix.enable = lib.mkIf cfg.terminal.helix (lib.mkDefault true);
          fastfetch.enable = lib.mkIf cfg.terminal.fastfetch (lib.mkDefault true);
          antigravity.enable = lib.mkIf cfg.terminal.antigravity (lib.mkDefault true);
          direnv.enable = lib.mkIf cfg.terminal.direnv (lib.mkDefault true);
        };

        utilities.filemanager.enable = lib.mkIf cfg.utilities.filemanager (lib.mkDefault true);
        office.ap-office.enable = lib.mkIf cfg.office.enable (lib.mkDefault true);
      };
    };
  };
}
