{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";

    home-manager = {
      url = "github:rycee/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    ...
  }: let
    inherit (lib.my) mapModulesRec;
    overlays = [];
    
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

    system = "x86_64-linux";
    pkgs = mkPkgs {inherit system overlays; pkgs = nixpkgs;};
    lib = nixpkgs.lib.extend (mkLib {inherit pkgs inputs;});
    modules = mapModulesRec ./modules import;
  in {inherit mkLib mkPkgs modules;};
}
