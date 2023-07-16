{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = inputs @ {nixpkgs, ...}: {
    mkLib = attrs @ {pkgs, inputs, ...}: (self: super: {
      my = import ./lib {
        inherit pkgs inputs;
        lib = self;
      };
    });

    mkPkgs = attrs @ {pkgs, overlays, system, ...}:
      import pkgs ({
        inherit system overlays;
        config.allowUnfree = true;
      } // attrs);
  };
}
