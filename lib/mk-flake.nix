inputs @ {
  nixpkgs,
  flake-parts,
  home-manager,
  ...
}: userConfig: let
  moduleDirs = import ./load-modules.nix userConfig;
  mkHost = import ./mk-host.nix;
in
  flake-parts.lib.mkFlake {
    # inputs from dx.nix
    # userConfig.inputs from user passed flake inputs
    inputs = inputs // userConfig.inputs;
  } {
    # the systems are used for perSystem
    systems = [
      "x86_64-darwin"
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ];

    imports = [
      flake-parts.flakeModules.modules
      home-manager.flakeModules.home-manager
      ({config, ...}: mkHost {inherit userConfig config inputs;})
      (inputs.import-tree moduleDirs)
    ];
  }
