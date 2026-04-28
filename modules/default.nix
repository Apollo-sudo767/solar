{ lib, isDarwin, ... }:

let
  inherit isDarwin;
  getNixFiles =
    dir:
    let
      contents = builtins.readDir dir;
    in
    lib.flatten (
      lib.mapAttrsToList (
        name: type:
        let
          path = "${toString dir}/${name}";
        in
        if type == "directory" then
          # Skip the hosts directory to prevent recursive loop
          if name == "hosts" then [ ] else getNixFiles path
        else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
          let
            # 1. Peek inside the file
            imported = import path;

            # 2. Extract its top-level arguments safely
            args = if builtins.isFunction imported then builtins.functionArgs imported else { };

            # 3. Detect your flags
            hasDarwin = args ? isDarwin;
            hasTotal = args ? isTotal;

            # 4. Implicit Linux Default
            isLinuxDefault = !hasDarwin && !hasTotal;
          in
          # --- THE ROUTING LOGIC ---
          if isDarwin then
            # On Mac: Only import files that explicitly have the isDarwin or isTotal flag
            if hasDarwin || hasTotal then path else [ ]
          else
          # On Linux: Import files that have the isTotal flag OR have no flags (Linux default)
          if isLinuxDefault || hasTotal then
            path
          else
            [ ]
        else
          [ ]
      ) contents
    );
in
{
  imports = getNixFiles ./.;

  # Inject the flags so modules that request them actually receive them
  _module.args = {
    inherit isDarwin;
    isTotal = true;
  };
}
