{
  config,
  options,
  lib,
  ...
}:
with lib;
with lib.my; {
  options = with types; {
    user = mkOpt attrs {};
    
    type = mkOpt str "";

    dotfiles = {
      dir = mkOpt path "";
      binDir = mkOpt path "${config.dotfiles.dir}/bin";
      configDir = mkOpt path "${config.dotfiles.dir}/config";
    };

    home = {
      configFile = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";
      dataFile = mkOpt' attrs {} "Files to place in $XDG_DATA_HOME";
    };

    env = mkOption {
      type = attrsOf (oneOf [str path (listOf (either str path))]);
      apply =
        mapAttrs
        (n: v:
          if isList v
          then concatMapStringsSep ":" (x: toString x) v
          else (toString v));
      default = {};
      description = "TODO";
    };

    core = {
      sessionVariables = mkOpt attrs {};
      extraInit = mkOpt lines "";

      userPackages = mkOpt (listOf package) [];
      packages = mkOpt (listOf package) [];
      fonts = mkOpt (listOf package) [];

      xserver = {
        enable = mkBoolOpt false;
        sessionCommands = mkOpt lines "";
        defaultSession = mkOpt str "";
        session = {
          name = mkOpt str "";
          start = mkOpt lines "";
        };
        wmCommand = mkOpt str "";
      };
    };
  };

  config = {
    user = let
      user = builtins.getEnv "USER";
      name = if elem user ["" "root"] then "mzanic" else user;
    in {
      inherit name;
      description = "The primary user account";
      extraGroups = ["wheel" "networkmanager" "audio" "video"];
      isNormalUser = true;
      home = "/home/${name}";
      group = "users";
      uid = 1000;
    };

    core.extraInit = 
      concatStringsSep "\n"
      (mapAttrsToList (n: v: "export ${n}=\"${v}\"") config.env);

    nix.settings = let
      users = ["root" config.user.name];
    in {
      trusted-users = users;
      allowed-users = users;
    };
  };
}
