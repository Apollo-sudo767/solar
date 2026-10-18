# templates/workstation.nix
# Template for creating a new functional workflow suite under modules/suites/
# Adheres strictly to "The Suite Law":
# Suites bundle functional workflows with lib.mkDefault. Styling, themes, and display managers
# are strictly declared per host leaf and NEVER leaked into suites.
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
