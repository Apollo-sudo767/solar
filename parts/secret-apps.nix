# parts/secrets-apps.nix
{ inputs, ... }:

{
  perSystem =
    { system, lib, ... }:
    {
      # Map applications out of the tracking schema context scope
      apps = {
        generate = {
          type = "app";
          program = lib.getExe inputs.agenix-rekey.packages.${system}.generate;
        };
        rekey = {
          type = "app";
          program = lib.getExe inputs.agenix-rekey.packages.${system}.rekey;
        };
        edit = {
          type = "app";
          program = lib.getExe inputs.agenix-rekey.packages.${system}.edit-view;
        };
      };
    };
}
