{
  config,
  options,
  lib,
  home-manager,
  ...
}:
with lib;
with lib.my; {
  options = with types; {
    home = {
      file = mkOpt' attrs {} "Files to place directly in $HOME";
    };
  };

  config = {
    type = "nixos";

    user.packages = mkAliasDefinitions options.core.userPackages;
    fonts.fonts = mkAliasDefinitions options.core.fonts;
    environment.systemPackages = mkAliasDefinitions options.core.packages;

    services.xserver = {
      enable = mkAliasDefinitions options.core.xserver.enable;
      displayManager = {
        defaultSession = mkAliasDefinitions options.core.xserver.defaultSession;
        sessionCommands = mkAliasDefinitions options.core.xserver.sessionCommands;
      };
      windowManager.session = [config.core.xserver.session];
    };

    home-manager = {
      useUserPackages = true;

      users.${config.user.name} = {
        home = {
          file = mkAliasDefinitions options.home.file;
          stateVersion = config.system.stateVersion;
        };
        xdg = {
          configFile = mkAliasDefinitions options.home.configFile;
          dataFile = mkAliasDefinitions options.home.dataFile;
        };
      };
    };

    users.users.${config.user.name} = mkAliasDefinitions options.user;

    env.PATH = ["$DOTFILES_BIN" "$XDG_BIN_HOME" "$PATH"];

    environment = {
      extraInit = mkAliasDefinitions options.core.extraInit;
      sessionVariables = mkAliasDefinitions options.core.sessionVariables;
    };
  };
}
