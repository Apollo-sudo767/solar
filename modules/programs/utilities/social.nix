{
  config,
  lib,
  pkgs,
  inputs,
  isTotal,
  ...
}:
let
  inherit isTotal;
  cfg = config.myFeatures.programs.utilities.social;
  spicetifyCfg = config.myFeatures.programs.utilities.spicetify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  options.myFeatures.programs.utilities.social.enable = lib.mkEnableOption "Spotify and Vesktop";
  options.myFeatures.programs.utilities.spicetify.enable =
    lib.mkEnableOption "Spicetify Integration"
    // {
      default = true;
    };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      imports = [
        inputs.spicetify-nix.homeManagerModules.default
      ];

      home.packages = lib.optional (!spicetifyCfg.enable) pkgs.spotify;

      programs.spicetify = lib.mkIf spicetifyCfg.enable {
        enable = true;
        enabledExtensions = with spicePkgs.extensions; [
          adblockify
          hidePodcasts
          shuffle
          fullAppDisplay
          keyboardShortcut
          history
        ];
        enabledCustomApps = with spicePkgs.apps; [
          lyricsPlus
          marketplace
        ];
      };

      programs.vesktop = {
        enable = true;
        settings = {
          discordBranch = "stable";
          hardwareAcceleration = true;
          vencord = {
            settings.plugins = {
              ChatInputButtonAPI.enabled = true;
              MemberCount.enabled = true;
            };
          };
        };
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          directories = lib.concatMap (name: [
            "/home/${name}/.config/spotify"
            "/home/${name}/.config/vesktop"
          ]) config.myFeatures.core.system.users.usernames;
        };
  };
}
