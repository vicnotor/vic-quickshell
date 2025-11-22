{
  description = "Vic's Quickshell flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    packages = forEachSupportedSystem ({pkgs}: rec {
      vic-quickshell = pkgs.callPackage ./default.nix {
        rev = self.rev or self.dirtyRev;
        quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };
      default = vic-quickshell;
    });

    devShells = forEachSupportedSystem ({pkgs}: let
      shell = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      run-vic-quickshell-from-here = pkgs.writeShellScriptBin "run-vic-quickshell-from-here" ''
        qs -p src
      '';
    in {
      default =
        pkgs.mkShellNoCC
        {
          inputsFrom = [shell];
          packages = with pkgs; [
            inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
            kdePackages.qtdeclarative # Contains qmlls and qmllint
            run-vic-quickshell-from-here
          ];
        };
    });
  };
}
