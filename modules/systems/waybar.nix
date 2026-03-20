{ pkgs, ... }: {
  flake.nixosModules.myFeatures.waybar = { ... }: {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (old: {
        mesonFlags = (old.mesonFlags or [ ]) ++ [
          "-Dexperimental=true"
          "-Dmpd=enabled"
          "-Dpulseaudio=enabled"
          "-Dmpris=enabled"
        ];
      });
    };
  };
}
