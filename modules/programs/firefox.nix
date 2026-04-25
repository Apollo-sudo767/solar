{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.firefox;
in
{
  options.myFeatures.programs.firefox.enable = lib.mkEnableOption "Enables Firefox";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # 1. NixOS System-wide Policies (Shielded)
      {
        programs.firefox = {
          enable = true;
          policies = {
            ExtensionSettings = {
              "uBlock0@raymondhill.net" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                installation_mode = "force_installed";
              };
              "{446900e4-71c2-419f-a6a7-df9c091e268b}".install_url =
                "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              # ... (keep your other extensions here)
            };
          };
        };
      }

      # 2. Home Manager (Works on both macOS and Linux)
      {
        home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
          stylix.targets.firefox.profileNames = [ name ];
          programs.firefox = {
            enable = true;
            profiles.${name} = {
              isDefault = true;
              settings = {
                # Use conditional path for downloads
                "browser.download.dir" =
                  if pkgs.stdenv.isDarwin then "/Users/${name}/Downloads" else "/home/${name}/Downloads";
                "browser.startup.page" = 3;
              };
            };
          };
        });
      }
    ]
  );
}
