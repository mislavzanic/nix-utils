{lib, ...}: import ./modules.nix {
  inherit lib;
  self.attrs = import ./attrs.nix {
    inherit lib;
    self = {};
  };
};
