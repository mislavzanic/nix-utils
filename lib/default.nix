{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  modules = import ./util.nix {inherit lib;};

  mylib = makeExtensible (self:
    with self;
      mapModules ./.
      (file: import file {inherit self lib pkgs inputs;}));
in
  mylib.extend
  (self: super:
    foldr (a: b: a // b) {} (attrValues super))
