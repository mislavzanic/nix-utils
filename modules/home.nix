{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  coreCfg = config.core;
in {
  options = with types; {
    genericLinux = mkBoolOpt false;
  };
  config = let
    sessionVars = concatStringsSep "\n" 
      (mapAttrsToList (n: v: "export ${n}=\"${v}\"") coreCfg.sessionVariables);
  in (mkMerge [
    {
      type = "home";

      programs.home-manager.enable = true;
      targets.genericLinux.enable = config.genericLinux;

      xsession = {
        enable = mkAliasDefinitions options.core.xserver.enable;
        windowManager.command = mkAliasDefinitions options.core.xserver.wmCommand;
        initExtra = concatStringsSep "\n"
          [config.core.extraInit config.core.xserver.sessionCommands];

        profileExtra = sessionVars;
      };

      home = {
        homeDirectory = config.user.home;
        username = config.user.name;
        packages = coreCfg.packages ++ coreCfg.fonts ++ coreCfg.userPackages;
      };
      xdg = {
        configFile = mkAliasDefinitions options.home.configFile;
        dataFile = mkAliasDefinitions options.home.dataFile;
      };
    }
    (mkIf (config.core.xserver.enable != true) {
      home.file.".profile".text = ''
        ${sessionVars}
        ${config.core.extraInit}
        if [ -e ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh ]; then 
          . ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh;
        fi
      '';
    })
  ]);
}
