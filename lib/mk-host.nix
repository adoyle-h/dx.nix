{
  inputs,
  config,
  userConfig,
}: let
  hostname = userConfig.runtime.hostname;
  host = userConfig.hosts.${hostname};
  backend = host.backend;
  system = host.system;
  features = host.features or [];

  # config.flake.modules.${backend} will override config.flake.modules.generic
  getFeatureModule = feature: let
    backendModules = config.flake.modules.${backend} or {};
    genericModules = config.flake.modules.generic or {};
  in
    if backendModules ? ${feature}
    then backendModules.${feature}
    else if genericModules ? ${feature}
    then genericModules.${feature}
    else
      throw ''
        Feature '${feature}' does not provide an implementation for flake.modules.${backend} or flake.modules.generic
      '';

  featureModules = map getFeatureModule features;

  commonModules = featureModules;

  nixosModules =
    commonModules
    ++ [
      inputs.home-manager.nixosModules.home-manager
    ];

  darwinModules =
    commonModules
    ++ [
      inputs.home-manager.darwinModules.home-manager
    ];

  systemManagerModules =
    commonModules
    ++ [
      inputs.home-manager.nixosModules.home-manager
      {
        nixpkgs.hostPlatform = system;
        system-manager = {
          allowAnyDistro = true;
        };
      }
    ];
in
  {
    nixos = assert backend == "nixos"; {
      flake.nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = nixosModules;
      };
    };

    darwin = assert backend == "darwin"; {
      flake.darwinConfigurations.${hostname} = inputs.nix-darwin.lib.darwinSystem {
        specialArgs = {inherit inputs;};
        modules = darwinModules;
      };
    };

    system-manager = assert backend == "system-manager"; {
      flake.systemConfigs.${hostname} = inputs.system-manager.lib.makeSystemConfig {
        specialArgs = {inherit inputs;};
        modules = systemManagerModules;
      };
    };
  }.${
    backend
  }
