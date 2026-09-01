{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.social;
in
{
  options.myFeatures.programs.utilities.social = {
    enable = lib.mkEnableOption "Social Suite (Communication & Music)";

    minimal = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use minimal / lightweight clients (Vesktop + Spotify Player) instead of full GUI clients (Spotify GUI + WebCord).";
    };

    vesktop.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Vesktop Discord client.";
    };

    spotify_player.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Spotify Player (TUI client).";
    };

    spotify.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Spotify GUI desktop client.";
    };

    webcord.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable WebCord Discord client.";
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.programs.utilities = {
      vesktop.enable = lib.mkIf cfg.vesktop.enable (lib.mkDefault true);
      spotify.tui.enable = lib.mkIf (cfg.spotify_player.enable || cfg.minimal) (lib.mkDefault true);
      spotify.enable = lib.mkIf (cfg.spotify.enable && !cfg.minimal) (lib.mkDefault true);
      webcord.enable = lib.mkIf (cfg.webcord.enable && !cfg.minimal) (lib.mkDefault true);
    };
  };
}
