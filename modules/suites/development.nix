{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.development;
in
{
  options.myFeatures.suites.development = {
    enable = lib.mkEnableOption "Advanced Development Suite (Helix, Git, Direnv, Nix-LD, Antigravity, Fastfetch)";

    helix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Helix modal text editor.";
      };
    };

    git = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Git version control.";
      };
    };

    direnv = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Direnv automatic environment switching.";
      };
    };

    nixLd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable nix-ld dynamic binary loader.";
      };
    };

    antigravity = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Antigravity AI pair programming assistant.";
      };
    };

    fastfetch = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Fastfetch system visualizer.";
      };
    };

    nh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable NH Nix CLI helper.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.programs.terminal = {
      helix.enable = lib.mkIf cfg.helix.enable (lib.mkDefault true);
      git.enable = lib.mkIf cfg.git.enable (lib.mkDefault true);
      direnv.enable = lib.mkIf cfg.direnv.enable (lib.mkDefault true);
      nix-ld.enable = lib.mkIf cfg.nixLd.enable (lib.mkDefault true);
      antigravity.enable = lib.mkIf cfg.antigravity.enable (lib.mkDefault true);
      fastfetch.enable = lib.mkIf cfg.fastfetch.enable (lib.mkDefault true);
      nh.enable = lib.mkIf cfg.nh.enable (lib.mkDefault true);
    };
  };
}
