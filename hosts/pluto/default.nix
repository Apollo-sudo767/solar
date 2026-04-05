{ lib, inputs, modulesPath, ... }:

{
  imports = [
    # Built-in NixOS module for generating AArch64 SD images
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  networking.hostName = "pluto";
  system.stateVersion = "25.11"; 

  myFeatures = {
    core.enable = true;
    shell.enable = true;
    core.boot.enable = lib.mkForce false;
    
    
    # Explicitly disable display manager for a lightweight SD image
    systems.displayManager.manager = lib.mkForce "none";
    
    services = {
      anytypeSync.enable = true; 
    };
    programs = {
      fastfetch.enable = true;
      helix.enable = true;
    };
    hardware = {
      pi3.enable = true;
    };
  };
}
