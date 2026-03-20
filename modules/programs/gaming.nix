{ ... }: {
  flake.nixosModules.myFeatures.gaming = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    
    environment.systemPackages = with pkgs; [
      prismlauncher
      mangohud
      gamemode
    ];
  };
}
