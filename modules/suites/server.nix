{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.server;
in
{
  options.myFeatures.suites.server = {
    enable = lib.mkEnableOption "Server Suite (Headless, Hardened SSH, Tailscale, Automated maintenance)";

    ssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable hardened key-only OpenSSH server daemon.";
      };
    };

    security = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable base security hardening profiles.";
      };
    };

    shell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable interactive CLI shell environment (Zsh + Starship).";
      };
    };

    tailscale = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Tailscale mesh node connectivity.";
      };
    };

    automation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automated Nix store garbage collection & maintenance.";
      };
    };

    lix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable modern Lix package engine.";
      };
    };

    udisks2 = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Udisks2 storage daemon.";
      };
    };

    nh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable nh (Nix Helper) CLI for fast rebuilds and automated cleaning.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      core = {
        security = {
          ssh.enable = lib.mkIf cfg.ssh.enable (lib.mkDefault true);
          security.enable = lib.mkIf cfg.security.enable (lib.mkDefault true);
        };
        shell = lib.mkIf cfg.shell.enable {
          cli.enable = lib.mkDefault true;
          shell.enable = lib.mkDefault true;
          shell-branch.enable = lib.mkDefault true;
        };
        nix = {
          automation.enable = lib.mkIf cfg.automation.enable (lib.mkDefault true);
          lix.enable = lib.mkIf cfg.lix.enable (lib.mkDefault true);
        };
      };

      programs = {
        terminal.nh.enable = lib.mkIf cfg.nh.enable (lib.mkDefault true);
      };

      services = {
        networking.tailscale.enable = lib.mkIf cfg.tailscale.enable (lib.mkDefault true);
        hardware.udisks2.enable = lib.mkIf cfg.udisks2.enable (lib.mkDefault true);
      };
    };
  };
}
