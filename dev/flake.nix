{
  description = "Development flake for nix-module-discovery";

  inputs = {
    files = {
      flake = false;
      url = "github:mightyiam/files/master";
    };
    flake-parts.url = "github:hercules-ci/flake-parts/main";
    terranix.url = "github:terranix/terranix/main";
    treefmt-nix.url = "github:numtide/treefmt-nix/main";
    nixpkgs.follows = "treefmt-nix/nixpkgs";
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      imports = [
        (inputs.files + "/flake-module.nix")
        inputs.terranix.flakeModule
        inputs.treefmt-nix.flakeModule
        ./github/ci.nix
        ./github/code_of_conduct.nix
        ./github/codeowners.nix
        ./github/contributing.nix
        ./github/dependabot.nix
        ./github/issues.nix
        ./github/license.nix
        ./github/pull_request_template.nix
        ./github/readme.nix
        ./github/repository.nix
      ];

      perSystem = _: {
        # The files flake lives in dev/, but generated files belong at the repo
        # root, so file checks must resolve paths relative to the Git top-level.
        files.gitToplevel = ../.;
        files.writer.app = true;
        terranix.exportDevShells = false;
        treefmt = {
          projectRootFile = "flake.nix";
          programs.deadnix.enable = true;
          programs.keep-sorted.enable = true;
          programs.nixfmt.enable = true;
          programs.statix.enable = true;
        };
      };
    };
}
