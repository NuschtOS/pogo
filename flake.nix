{
  inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    flake-utils.url = "github:numtide/flake-utils";

    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    namaka = {
      url = "github:nix-community/namaka";
      inputs = {
        haumea.follows = "haumea";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, disko, flake-utils, namaka, nixpkgs, ... }: {
    nixosModules = rec {
      default = pogo;
      pogo.imports = [
        disko.nixosModules.disko
        ./modules
      ];
    };
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      checks = namaka.lib.load {
        src = ./tests;
        inputs = let
          inherit (nixpkgs) lib;
        in {
          eval = attrs: let
            inherit (nixpkgs.lib.nixosSystem {
              modules = [
                {
                  nixpkgs.hostPlatform = system;
                }
                self.nixosModules.pogo
                attrs
              ];
            }) config;
          in
            assert config.system.build.diskoScript.outPath != "";
          {
            # only compare some key values to not break on every change
            boot = {
              initrd.luks.devices = lib.mapAttrs (n: v: lib.filterAttrs (n: v: lib.any (x: x == n ) [
                "device"
                "name"
              ]) v) config.boot.initrd.luks.devices;

              loader.grub = {
                mirroredBoots = map (device: { inherit (device) devices path; }) config.boot.loader.grub.mirroredBoots;
              };
            };
            disko.devices.disk = lib.mapAttrs (n: v: {
              content.partitions = map (v: {
                inherit (v) start end;
              }) v.content.partitions;
            }) config.disko.devices.disk;

            fileSystems = lib.mapAttrs (n: v: lib.filterAttrs (n: v: lib.any (x: x == n) [
              # # descend into all entries
              # lib.hasPrefix "/" n ||
              "depends"
              "device"
              "fsType"
              "mountPoint"
              "neededForBoot"
              "options"
            ]) v) config.fileSystems;

            inherit (config) swapDevices;
          };
        };
      };

      devShells.default = pkgs.mkShell {
        packages = [
          namaka.packages.${system}.default
        ];
      };
    });
}
