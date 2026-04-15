{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.crane.url = "github:ipetkov/crane";
  
  outputs = { self, nixpkgs, flake-utils, crane }: 
    flake-utils.lib.eachSystem flake-utils.lib.allSystems (system: 
      let
        pkgs = import nixpkgs { inherit system; };
        craneLib = crane.mkLib pkgs;

        commonArgs = {
          src = craneLib.cleanCargoSource ./.;
          strictDeps = true;

          nativeBuildInputs = with pkgs; [];
          buildInputs = with pkgs; [];
        };

        cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        myCrate = craneLib.buildPackage (commonArgs // {
          inherit cargoArtifacts;
        });

      in {
        packages.default = myCrate;

        devShells.default = craneLib.devShell {
          checks = self.checks.${system};
          inputsFrom = [ cargoArtifacts ];
        };

        checks = {
          inherit myCrate;
          clippy = craneLib.cargoClippy (commonArgs // {
            inherit cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets --all-features -- --deny warnings";
          });
          fmt = craneLib.cargoFmt commonArgs;
          doc = craneLib.cargoDoc (commonArgs // {
            inherit cargoArtifacts;
            env.RUSTDOCFLAGS = "--deny warnings";
          });
        };

        apps.default = flake-utils.lib.mkApp {
          drv = myCrate;
        };
      }
    );
}