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

  users.users.apollo.hashedPassword = "$6$uEe7O.pykcuIaZVc$oCGnxu68r7wpVkOAhJiXC.TGDwE6kETEYQTWCl.Y1Vsxn21WgRkjsuv0sTXB0ygf1duIJytQ6h3TgLmjVuKbr/";
}
