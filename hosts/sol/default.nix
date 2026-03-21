{ lib, inputs, ... }:

{

  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "sol";
  system.stateVersion = "26.05";

  myFeatures = {
    core.enable = true;
    shell.enable = true;
    hardware = {
      amd.enable = true;
      nvidia.enable = false;
      bluetooth.enable = true;
    };
    systems.presets.gruvboxNiri.enable = true;
    programs.terminal.enable = true;
    programs.gaming.enable = true;
  };
}
