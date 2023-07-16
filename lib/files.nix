{
  self,
  lib,
  ...
}: let
  inherit (builtins) readDir pathExists;
  inherit (lib) hasPrefix hasSuffix nameValuePair collect isString concatStringsSep mapAttrsRecursive;
  inherit (self.attrs) mapFilterAttrs;
in rec {
  files = dir: collect isString (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

  getDir = dir:
    mapFilterAttrs
    (file: type: type != null && !(hasPrefix "__" file))
    (file: type: let
      path = "${toString dir}/${file}";
    in
      if type == "directory" && pathExists "${path}/default.nix"
      then nameValuePair path type
      else if type == "regular" && file != "default.nix" && hasSuffix ".nix" file
      then nameValuePair path type
      else nameValuePair "" null)
    (readDir dir);
}
