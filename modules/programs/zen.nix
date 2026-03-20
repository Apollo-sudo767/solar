{ pkgs, lib, config }:

let
  cfg = config.myFeatures.programs.zen;
in
{
  options.myFeatures.programs.zen = {
    enable = lib.mkEnableOption "Enables Zen Browser";
  };

  config = lib.mkIf cfg.enable {

    # System-wide package (assuming it's in your nixpkgs or an overlay)
    environment.systemPackages = [ pkgs.zen-browser ];

    # Optional: Desktop integration for your 'solar' theme
    home-manager.users.apollo = {
      home.file.".config/zen/themes/gruvbox".source = ../../assets/wallpapers/gruvbox.jpg;
    };
  };
}
