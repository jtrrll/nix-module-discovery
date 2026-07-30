{
  config.perSystem =
    { pkgs, ... }:
    let
      yaml = pkgs.formats.yaml { };

      nixInstallerStep = {
        uses = "DeterminateSystems/nix-installer-action@v22";
      };

      checkoutStep = {
        uses = "actions/checkout@v7";
      };

      generated = yaml.generate "ci.yaml" {
        name = "CI";
        "on" = {
          pull_request.branches = [ "*" ];
          push.branches = [ "main" ];
          schedule = [ { cron = "0 06 * * MON"; } ];
          workflow_dispatch = { };
        };
        concurrency = {
          cancel-in-progress = true;
          group = "\${{ github.workflow }}-\${{ github.ref }}";
        };
        jobs.check = {
          name = "Check";
          runs-on = "ubuntu-latest";
          steps = [
            checkoutStep
            nixInstallerStep
            { uses = "DeterminateSystems/flake-checker-action@v12"; }
            {
              name = "Check flake";
              run = "nix flake check";
            }
          ];
        };
      };
    in
    {
      config.files.file.".github/workflows/ci.yaml".source =
        pkgs.runCommand "ci.yaml" { nativeBuildInputs = [ pkgs.yq-go ]; }
          ''
            yq '
              pick(["name", "on", "concurrency", "jobs"]) |
              .jobs[] |= pick(["name", "runs-on", "steps"]) |
              .jobs[].steps[] |= pick(["name", "uses", "with", "run"])
            ' ${generated} > $out
          '';
    };
}
