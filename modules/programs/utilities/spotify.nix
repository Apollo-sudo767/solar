{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.spotify;
  spicetifyCfg = config.myFeatures.programs.utilities.spicetify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  spotify-wrapped = pkgs.spotify.overrideAttrs (oldAttrs: {
    postFixup = (oldAttrs.postFixup or "") + ''
      # Edit the wrapper script to inject --password-store=gnome-libsecret
      sed -i 's|exec -a "$0" \("[^"]*"\) *"$@"|exec -a "$0" \1 --password-store=gnome-libsecret "$@"|g' $out/share/spotify/spotify
    '';
  });
in
{
  options.myFeatures.programs.utilities.spotify.enable = lib.mkEnableOption "Spotify";
  options.myFeatures.programs.utilities.spicetify.enable =
    lib.mkEnableOption "Spicetify Integration"
    // {
      default = true;
    };

  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = lib.mkDefault pkgs.stdenv.isLinux;

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      imports = [
        inputs.spicetify-nix.homeManagerModules.default
      ];

      home.packages = lib.optional (!spicetifyCfg.enable) spotify-wrapped;

      programs.spicetify = lib.mkIf spicetifyCfg.enable {
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
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/spotify"
              ".cache/spotify"
            ];
          });
        };
  };
}
