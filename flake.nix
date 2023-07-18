{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:rycee/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  }: let
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

  in
    flake-utils.lib.eachDefaultSystem (system: let
      inherit (lib.my) mapModulesRec;
      pkgs = mkPkgs {inherit system; pkgs = nixpkgs;};
      lib = nixpkgs.lib.extend (mkLib {inherit pkgs inputs;});
    in {
      modules = mapModulesRec ./modules import;
    }) // { inherit mkLib mkPkgs; };
}
