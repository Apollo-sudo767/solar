{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.fuzzel;
  inherit (config.myFeatures.core.system.users) usernames;
in
{
  options.myFeatures.platforms.addons.fuzzel = {
    enable = lib.mkEnableOption "Fuzzel according to stylix";
  };

  config =
    lib.mkIf
      (
        cfg.enable
        && !config.myFeatures.platforms.addons.noctalia-shell.enable
        && !config.myFeatures.platforms.addons.noctalia-v5.enable
      )
      {
        environment.systemPackages = [ pkgs.fuzzel ];
        home-manager.users = lib.genAttrs usernames (_name: {
          # This allows Stylix to take over Fuzzel styling
          programs.fuzzel = {
            enable = true;
            settings = {
              main = {
                terminal = "${pkgs.ghostty}/bin/ghostty";
                layer = "overlay";
                font = lib.mkForce "JetBrainsMono Nerd Font:size=12";
                prompt = "'❯ '";
                icons-enabled = true;
                width = 40;
                horizontal-pad = 20;
                vertical-pad = 20;
                inner-pad = 10;
              };
              border.radius = lib.mkForce 0;
              border.width = 2;
            };
          };
        });
      };
}
