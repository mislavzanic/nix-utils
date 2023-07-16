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
  };
}
