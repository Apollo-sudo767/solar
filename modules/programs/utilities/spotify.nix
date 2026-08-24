{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.spotify;
  tuiCfg = cfg.tui;
  spicetifyCfg = config.myFeatures.programs.utilities.spicetify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  spotify-wrapped = pkgs.spotify.overrideAttrs (oldAttrs: {
    postFixup = (oldAttrs.postFixup or "") + ''
      # Edit the wrapper script to inject --password-store=basic
      sed -i 's|exec -a "$0" \("[^"]*"\) *"$@"|exec -a "$0" \1 --password-store=basic "$@"|g' $out/share/spotify/spotify
    '';
  });

  guiEnabled = cfg.gui.enable || cfg.enable;
  anyEnabled = guiEnabled || tuiCfg.enable;
in
{
  options.myFeatures.programs.utilities.spotify = {
    enable = lib.mkEnableOption "Spotify GUI client";
    gui.enable = lib.mkEnableOption "Spotify GUI client";
    tui.enable = lib.mkEnableOption "Spotify TUI client (spotify-player)";
  };
  options.myFeatures.programs.utilities.spicetify.enable =
    lib.mkEnableOption "Spicetify Integration"
    // {
      default = true;
    };

  config = lib.mkIf anyEnabled {
    services.gnome.gnome-keyring.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      imports = [
        inputs.spicetify-nix.homeManagerModules.default
      ];

      home.packages = lib.optional (guiEnabled && !spicetifyCfg.enable) spotify-wrapped;

      programs.spotify-player = lib.mkIf tuiCfg.enable {
        enable = true;
      };

      programs.spicetify = lib.mkIf (guiEnabled && spicetifyCfg.enable) {
        enable = true;
        spotifyPackage = spotify-wrapped;
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
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.hostPlatform.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories =
              (lib.optionals guiEnabled [
                ".config/spotify"
                ".cache/spotify"
                ".local/share/spotify"
              ])
              ++ (lib.optionals tuiCfg.enable [
                ".cache/spotify-player"
              ]);
          });
        };
  };
}
