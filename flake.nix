{
  inputs = {};

  outputs = inputs: let
    mkLib = attrs @ {pkgs, inputs, ...}: (self: super: {
      my = import ./lib {
        inherit pkgs inputs;
        lib = self;
      };
    });

    mkPkgs = attrs @ {pkgs, overlays ? [], system, ...}:
      import pkgs ({
        inherit system overlays;
        config.allowUnfree = true;
      } // attrs);
  in {inherit mkLib mkPkgs;};
}
