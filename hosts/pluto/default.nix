{ lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pluto";
  system.stateVersion = "24.11"; 

  myFeatures = {
    core.enable = true; # Enables basic users, ssh, and nix settings
    services = {
      anytypeSync.enable = true; # New feature toggle
    };
  };
}
