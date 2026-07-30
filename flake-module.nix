{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.moduleDiscovery;
  discoveryLib = import ./lib.nix { inherit lib; };
in
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  options.moduleDiscovery = {
    path = lib.mkOption {
      type = lib.types.addCheck lib.types.path lib.pathIsDirectory // {
        description = "path to a directory";
      };
      example = lib.literalExpression "./modules";
      description = ''
        Directory to scan for modules. It is expected to contain per-class
        subdirectories, and within each a module is either a single
        `<name>.nix` file or a `<name>/` directory whose `.nix` files (recursed)
        are merged into one module. Discovered modules populate
        `flake.modules.<class>.<name>`.
      '';
    };

    transform = lib.mkOption {
      type = lib.types.functionTo (lib.types.functionTo (lib.types.functionTo lib.types.attrs));
      default = class: name: module: {
        inherit class name module;
      };
      defaultText = lib.literalExpression "class: name: module: { inherit class name module; }";
      description = ''
        Receives the raw class, raw name, and the built module, and returns the
        final `{ class, name, module }`. May remap the class, rename the module,
        or edit the module. Defaults to identity.
      '';
    };
  };

  config.flake.modules = discoveryLib.modulesByClassAndName {
    inherit (cfg) path transform;
  };
}
