{
  description = "";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
  in {
    packages = builtins.genAttrs systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.runCommand "dx.nix" {} ''
        mkdir -p $out/bin/cmds
        cp -r ${./bin}/* $out/bin/
        chmod -R +x $out/bin/*
      '';
    });
  };
}
