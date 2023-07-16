{
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  sys = "x86_64-linux";
in {
  mkHost = path: attrs @ {system ? sys, defaults, ...}:
    nixosSystem {
      inherit system;
      specialArgs = {inherit lib inputs system;};
      modules = [
        {
          nixpkgs.pkgs = pkgs;
          networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
        }
        (filterAttrs (n: v: !elem n ["system" "defaults"]) attrs)
        (import defaults)
        (import path)
      ];
    };

  mapHosts = dir: attrs @ {system ? system, defaults, ...}:
    mapModules dir
    (hostPath: mkHost hostPath attrs);

  mapShell = dir: attrs:
    mapModules dir
    (shellPath: import shellPath attrs);
}
