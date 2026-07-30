{
  config.perSystem = _: {
    config.files.file."README.md".text = ''
      # nix-module-discovery

      Automatically discover and import Nix modules from a directory tree, where the
      layout encodes each module's class.

      It exposes its functionality two ways:

      - **`lib`** — pure functions (`flake.lib`) you can call directly, with no
        dependency on flake-parts.
      - **flake-parts module** — `flakeModules.default`, which wires discovered
        modules into `flake.modules.<class>.<name>` for you.

      ## Layout

      ```
      modules/
        <class>/                 # e.g. nixos, homeManager
          <name>.nix             # a single-file module
          <name>/                # a multi-file module: every *.nix beneath it
            *.nix                # (recursively) is merged into one module via imports
      ```

      Each discovered module is stamped with `_class` and `_file`. The class and
      module names are the directory/file names verbatim; use `transform` to rewrite
      them (e.g. `home_manager` -> `homeManager`) or edit the module.

      ## Usage (flake-parts module)

      ```nix
      {
        inputs = {
          flake-parts.url = "github:hercules-ci/flake-parts";
          nix-module-discovery.url = "github:jtrrll/nix-module-discovery";
        };

        outputs = inputs@{ flake-parts, nix-module-discovery, ... }:
          flake-parts.lib.mkFlake { inherit inputs; } {
            imports = [ nix-module-discovery.flakeModules.default ];
            systems = [ "x86_64-linux" ];

            moduleDiscovery.path = ./modules;
          };
      }
      ```

      Given the layout above, this populates:

      - `flake.modules.nixos.<name>`
      - `flake.modules.homeManager.<name>`

      ### Options

      - `moduleDiscovery.path` (path) — directory to scan.
      - `moduleDiscovery.transform` (class -> name -> module -> `{ class, name, module }`)
        — receives the raw class, raw name, and built module; returns the final class
        key, attribute name, and module. May remap the class, rename the module, or
        edit it. Default: identity.

      ## Usage (library)

      The pure functions are exposed under `flake.lib`, usable without flake-parts:

      ```nix
      {
        inputs.nix-module-discovery.url = "github:jtrrll/nix-module-discovery";

        outputs = { nix-module-discovery, ... }:
          let
            modules = nix-module-discovery.lib.modulesByClassAndName { path = ./modules; };
          in
          { /* modules == { <class>.<name> = <module>; ... } */ };
      }
      ```

      - `modulesByClassAndName { path, transform ? ... }` — `transform` returns `{ class, name, module }`
      - `nixFilesInDir { path, recurse ? false }`
    '';
  };
}
