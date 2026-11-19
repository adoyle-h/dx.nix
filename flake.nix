{
  description = "A simple nix system framework which follows the Dendritic Pattern";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:denful/import-tree";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    system-manager.url = "github:numtide/system-manager";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin?ref=master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager?ref=release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
  in {
    mkFlake = import ./lib/mk-flake.nix inputs;

    packages = nixpkgs.lib.genAttrs systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default =
        pkgs.runCommand "dx.nix" {
          nativeBuildInputs = [
            pkgs.installShellFiles
          ];
        } ''
          mkdir -p $out/bin/cmds
          cp -r ${./bin}/* $out/bin/
          chmod -R +x $out/bin/*

          installShellCompletion --bash ${./bin/completions/dx.nix.bash}
        '';
    });
  };
}
