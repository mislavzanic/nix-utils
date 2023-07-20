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
    system = "x86_64-linux";

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

    pkgs = mkPkgs {inherit system; pkgs = nixpkgs;};
    lib = nixpkgs.lib.extend (mkLib {inherit pkgs inputs;});
  in {
    homeManager = import ./home.nix;
  } // { inherit mkLib mkPkgs; };
}
