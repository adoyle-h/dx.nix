# dx.nix

A simple nix system framework which follows the [Dendritic Pattern](https://github.com/mightyiam/dendritic).

## Features

- It supports NixOS, MacOS, and any Linux systems.
- It uses [flake.nix](https://wiki.nixos.org/wiki/Flakes) and `dx.nix` command to manage settings.
- It manages modules via [flake-parts](https://github.com/hercules-ci/flake-parts). User should pass argument `moduleDirs` to `inputs.dx-nix.mkFlake`.
- It is just a modular framework. No providing any builtin modules.
- It includes [nix-darwin](https://github.com/nix-darwin/nix-darwin), [home-manager](https://github.com/nix-community/home-manager), [system-manager](https://github.com/numtide/system-manager), [sops-nix](https://github.com/Mic92/sops-nix). See [./flake.nix](./flake.nix) for details.

## Installation

`nix profile add github:adoyle-h/dx.nix`

and type `dx.nix` for help.

## Quick Start

### File Structure

```
./
├── features/
│   ├── linux.nix
│   ├── macos.nix
│   └── nix.nix
├── users/
│   ├── user-1.nix
│   ├── user-2.nix
│   └── root.nix
└── flake.nix
```

### flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    dx-nix.url = "github:adoyle-h/dx.nix";
    dx-nix.inputs.nixpkgs.follows = "nixpkgs";
    # dx.nix will create ~/.cache/dx.nix/runtime and rewrite the path, don't modify it
    dx-nix-runtime.url = "path:~/.cache/dx.nix/runtime";
    # other third nix flake
  };

  outputs = inputs:
    inputs.dx-nix.mkFlake {
      inherit inputs;

      runtime = inputs.dx-nix-runtime;

      # The framework auto recursively imports modules from these directories.
      # All module files should flatten in each folder. No nested folder.
      # All modules in ./features and ./users are same, no differences, just different parent folders.
      moduleDirs = [
        ./features
        ./users
      ];

      hosts = {
        # The host name should same to the value of `hostname -s` on your current host.
        nixos1 = {
          # The `backend` valid values: `nixos`, `darwin`, `system-manager`.
          backend = "nixos";
          system = "aarch64-linux";
          # The features must be the filename listed in moduleDirs
          features = [
            "nix"
            "linux"
            "cli"
          ];
        };

        MBP = {
          backend = "darwin";
          system = "aarch64-darwin";
          features = [
            "nix"
            "macos"
            "cli"
          ];
        };

        arch = {
          backend = "system-manager";
          system = "x86_64-linux";

          features = [
            "nix"
            "linux"
            "cli"
          ];
        };
      };
    };
}
```

### Module

All modules should be [flake-parts modules](https://flake.parts/options/flake-parts-modules.html#opt-flake.modules).

For example, create a file at `features/cli.nix`.

```nix
{
  # Note that if you use the args@{ ... } or args: syntax,
  # you only receive the arguments you explicitly name in the function signature;
  # see https://flake.parts/module-arguments.html
  flake.modules.generic.cli = args@{pkgs, lib, ...}: {
    environment.systemPackages = with pkgs; [
      stdenv.cc
      binutils
      gnumake
      neovim
      tmux
    ];
  };
}
```


```nix
{
  # The flake.modules.generic/darwin/nixos/system-manager.* are optional.

  flake.modules.generic.cli = {lib, ...}: {
  };

  # If your host is MacOS and flake.modules.darwin.cli set,
  # flake.modules.generic.cli will be ignored.
  flake.modules.darwin.cli = {lib, ...}: {
  };

  # If your host is NixOS and flake.modules.nixos.cli set,
  # flake.modules.generic.cli will be ignored.
  flake.modules.nixos.cli = {lib, ...}: {
  };

  # If your host is any Linux system and flake.modules.system-manager.cli set,
  # flake.modules.generic.cli will be ignored.
  flake.modules.system-manager.cli = {lib, ...}: {
  };
}
```

#### Home-Manager

```nix
# It supports flake.homeConfigurations and flake.homeModules.
{
  # https://flake.parts/options/home-manager.html#opt-flake.homeConfigurations
  flake.homeConfigurations.xxx = {
  };

  # https://flake.parts/options/home-manager.html#opt-flake.homeModules
  flake.homeModules.yyy = {
    home = {
      username = "root";
      homeDirectory = "/root";
      stateVersion = "26.05";
    };
  };
}
```

```nix
# Although it supports flake.homeConfigurations and flake.homeModules.
# I recommend to set home-manager.users in flake.modules.generic.*.
{
  inputs,
  self,
  ...
}: let
  username = "adoyle";
  homeModules_adoyle = { config, options, pkgs, ... }: {
    imports = []; # import home-manager modules

    home = {
      username = username;
      stateVersion = "26.05";
    };
  };
in
flake.modules.generic.adoyle = {
  home-manager.users.adoyle = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      homeModules_adoyle
      # Import other home-manager modules via self.homeModules.*
      self.homeModules.ssh
    ];
    home = {
      homeDirectory = "/home/adoyle";
    };
  };
}
```

### Commands

- `dx.nix switch` : build and apply. It will automatically identify the operating system and hostname. Your hostname (`hostname -s`) must be same with the attribution name of `hosts` in `inputs.dx-nix.mkFlake { hosts }`.
- `dx.nix build` : build. It will automatically identify the operating system and hostname. Your hostname (`hostname -s`) must be same with the attribution name of `hosts` in `inputs.dx-nix.mkFlake { hosts }`.
- `dx.nix eval #path` : for debug


## Secrets

dx.nix uses [sops.nix](https://github.com/mic92/sops-nix) to manage secrets.

For example, following the [sops-nix#usage-example](https://github.com/mic92/sops-nix#usage-example) to create a file `secrets/secret.yaml` and `.sops.yaml` in your folder.


```
./
├── features/
│   ├── linux.nix
│   ├── nix.nix
│   ├── macos.nix
│   └── sops.nix
├── users/
│   ├── user-1.nix
│   ├── user-2.nix
│   └── root.nix
├── secrets/
│   └── secret.yaml
├── .sops.yaml
└── flake.nix
```

`sops secrets/secret.yaml` to edit your secrets.

put your age key to `/var/lib/sops-nix/key.txt` (the age key must be out of your flake folder)

And create a file `features/sops.nix`.

```nix
{inputs, ...}: {
  flake.modules.generic.sops = {pkgs, ...}: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops = {
      defaultSopsFile = ../secrets/generic.yaml;
      # keyFile should be pathNotInStore
      age.keyFile = "/var/lib/sops-nix/key.txt";
    };
  };
}
```

## Development

`nix profile add github:adoyle-h/dx.nix/develop` to get dx.nix from the develop branch.

## Suggestion, Bug Reporting, Contributing

**Before opening new Issue/Discussion/PR and posting any comments**, please read [Contributing Guidelines](https://gcg.adoyle.me/CONTRIBUTING).

## Copyright and License

Copyright 2026 ADoyle (adoyle.h@gmail.com). Some Rights Reserved.
The project is licensed under the **Apache License Version 2.0**.

Read the [LICENSE][] file for the specific language governing permissions and limitations under the License.

Read the [NOTICE][] file distributed with this work for additional information regarding copyright ownership.


<!-- links -->

[LICENSE]: ./LICENSE
[NOTICE]: ./NOTICE
