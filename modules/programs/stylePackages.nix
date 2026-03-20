{ ... }: {
  flake.nixosModules.myFeatures.stylePackages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      cbonsai
      cmatrix
      pipes
      asciiquarium
      cava
      vitetris
    ];
  };
}
