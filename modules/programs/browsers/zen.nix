{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.programs.browsers.zen;
  # Ported from Phanes desktop.nix
  # This uses the flake input to apply your specific security policies
  myZen = inputs.zen-browser.packages."${pkgs.system}".default.override {
    extraPolicies = {
      DisableTelemetry = true;
      ExtensionSettings = {
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
in
{
  options.myFeatures.programs.browsers.zen.enable =
    lib.mkEnableOption "Zen Browser with Phanes Overrides";

  config = lib.mkIf cfg.enable {
    # Install your customized Zen package system-wide
    environment.systemPackages = [ myZen ];

    # Optional: Set as default browser if desired
    # home-manager.users.apollo.home.sessionVariables.BROWSER = "zen";
  };
}
