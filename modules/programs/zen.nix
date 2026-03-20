{ ... }: {
  flake.nixosModules.myFeatures.zen = { pkgs, ... }: {
    # System-wide package (assuming it's in your nixpkgs or an overlay)
    environment.systemPackages = [ pkgs.zen-browser ];

    # Optional: Desktop integration for your 'solar' theme
    home-manager.users.apollo = {
      home.file.".config/zen/themes/gruvbox".source = ../../assets/wallpapers/gruvbox.jpg;
    };
  };
}
