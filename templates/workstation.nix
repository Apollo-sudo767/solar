# templates/workstation.nix
# ============================================================================
# Functional Workflow Suite Template (`modules/suites/<name>.nix`)
# ============================================================================
# Suites group related leaf features (`modules/programs/*`, `modules/services/*`)
# into high-level toggles (like `workstation`, `gaming`, `laptop`, `server`).
#
# Architectural Rules ("The Suite Law"):
# 1. Always use `lib.mkDefault true` when enabling leaf features inside a suite
#    so individual hosts can easily override or disable specific tools.
# 2. Expose granular sub-options (defaulting to `true`) so hosts can opt out of
#    entire categories or individual programs cleanly.
# 3. NEVER put themes (`stylix`, `flavors`, `themes`) or display managers inside
#    a functional workflow suite—visual identity is strictly chosen per host leaf.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.customSuite;
in
{
  options.myFeatures.suites.customSuite = {
    enable = lib.mkEnableOption "Custom Functional Workflow Suite";
    browser = lib.mkEnableOption "Default browser bundle" // {
      default = true;
    };
    terminal = lib.mkEnableOption "Terminal developer tools" // {
      default = true;
    };
    utilities = lib.mkEnableOption "Everyday utilities" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      programs = {
        # Browsers
        browsers = lib.mkIf cfg.browser {
          firefox.enable = lib.mkDefault true;
        };

        # Terminal & Development
        terminal = lib.mkIf cfg.terminal {
          helix.enable = lib.mkDefault true;
          ghostty.enable = lib.mkDefault true;
          git.enable = lib.mkDefault true;
          nh.enable = lib.mkDefault true;
        };

        # Everyday Utilities
        utilities = lib.mkIf cfg.utilities {
          bitwarden.enable = lib.mkDefault true;
          filemanager.enable = lib.mkDefault true;
          social.enable = lib.mkDefault true;
        };
      };

      # System Services
      services = {
        multimedia.audio.enable = lib.mkDefault true;
        hardware.printing.enable = lib.mkDefault true;
      };
    };
  };
}
