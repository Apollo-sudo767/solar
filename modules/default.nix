{
  lib,
  isDarwin,
  ...
}:

let
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

            # 3. Detect flags
            hasDarwin = args ? isDarwin;
            hasTotal = args ? isTotal;

            # Platform segregation
            isInDarwin = lib.hasInfix "/modules/darwin/" (toString path);
            isInDisplayManager = lib.hasInfix "/displayManager/" (toString path);

            shouldImport =
              if isDarwin then (isInDarwin || hasDarwin || hasTotal) && !isInDisplayManager else !isInDarwin;
          in
          if shouldImport then path else [ ]
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
