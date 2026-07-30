{
  description = "Automatically discover and import Nix modules";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib/master";
  };

  outputs =
    { nixpkgs-lib, ... }:
    {
      flakeModules.default = ./flake-module.nix;
      lib = import ./lib.nix { inherit (nixpkgs-lib) lib; };

      inherit (builtins.getFlake ./dev) apps checks formatter;
    };
}
