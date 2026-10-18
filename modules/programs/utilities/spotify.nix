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
    preFixup = (oldAttrs.preFixup or "") + ''
      gappsWrapperArgs+=(--add-flags "--password-store=basic")
    '';
  });

  tuiPlayerCfg = config.myFeatures.programs.utilities.spotify_player.enable or false;
  tuiPlayerHyphenCfg = config.myFeatures.programs.utilities.spotify-player.enable or false;
  tuiEnabled = tuiCfg.enable || tuiPlayerCfg || tuiPlayerHyphenCfg;

  guiEnabled = cfg.gui.enable || cfg.enable;
  anyEnabled = guiEnabled || tuiEnabled;
in
{
  options.myFeatures.programs.utilities.spotify = {
    enable = lib.mkEnableOption "Spotify GUI client";
    gui.enable = lib.mkEnableOption "Spotify GUI client";
    tui.enable = lib.mkEnableOption "Spotify TUI client (spotify-player)";
  };
  # Backward compatibility aliases
  options.myFeatures.programs.utilities.spotify_player.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Deprecated: use myFeatures.programs.utilities.spotify.tui.enable instead.";
  };
  options.myFeatures.programs.utilities.spotify-player.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Deprecated: use myFeatures.programs.utilities.spotify.tui.enable instead.";
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

      programs.spotify-player = lib.mkIf tuiEnabled {
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
              ++ (lib.optionals tuiEnabled [
                ".cache/spotify-player"
              ]);
          });
        };
  };
}
