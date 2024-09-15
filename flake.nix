{
  description = "F# Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      devenv,
      nixpkgs,
      ...
    }:
    let
      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
        }
      );
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor."${system}";
          name = "sample";
          version = "0.1.0";
        in rec
        {
          # `nix build`
          default = pkgs.buildDotnetModule {
            pname = name;
            version = version;
            src = ./.;
            projectFile = "src/App/App.fsproj";
            nugetDeps = ./deps.nix;

            dotnet-sdk =
              with pkgs.dotnetCorePackages;
              combinePackages [
                sdk_8_0
              ];
            dotnet-runtime = pkgs.dotnetCorePackages.sdk_8_0;
          };

          # nix build .#dockerImage
          dockerImage = pkgs.dockerTools.buildLayeredImage {
            name = "sample";
            tag = "latest";
            created = "now";
            contents = [ default ];
            config = {
              Cmd = [
                "${default}/bin/App"
              ];
            };
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor."${system}";
          dotnet =
            with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_8_0
            ];
        in
        {
          # `nix develop .#ci`
          # reduce the number of packages to the bare minimum needed for CI
          ci = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              just
              dotnet
            ];
          };

          # `nix develop --impure`
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              (
                { pkgs, lib, ... }:
                {
                  packages = with pkgs; [
                    bash
                    just

                    # for dotnet
                    netcoredbg
                    fsautocomplete
                    fantomas
                  ];

                  languages.dotnet = {
                    enable = true;
                    package = dotnet;
                  };

                  # looks for the .env by default additionaly, there is .filename
                  # if an arbitrary file is desired
                  dotenv.enable = true;
                }
              )
            ];
          };
        }
      );

      # nix fmt
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
