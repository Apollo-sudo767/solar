# parts/hosts.nix
# ============================================================================
# Flake Host Output Bridge
# ============================================================================
# Connects the automated host loader (`modules/hosts/default.nix`) and the
# Dendritic feature autoscanner (`modules/default.nix`) to the top-level
# `flake.nixosConfigurations` and `flake.darwinConfigurations` outputs.
{ inputs, ... }:

{
  flake =
    let
      inherit (inputs.nixpkgs-unstable) lib;

      # Invoke the automated host loader, passing the Dendritic module tree
      # (`../modules/default.nix`) as the global baseline for every host.
      hostLoader = import ../modules/hosts/default.nix {
        inherit lib inputs;
        globalModules = [ ../modules/default.nix ];
      };
    in
    {
      inherit (hostLoader) nixosConfigurations darwinConfigurations;
    };
}
