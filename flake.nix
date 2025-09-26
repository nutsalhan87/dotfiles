{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable-nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-colorizer.url = "github:nutsalhan87/nix-colorizer";
    
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    nixpkgs, 
    stable-nixpkgs, 
    nix-colorizer, 
    nixos-hardware, 
    fenix, 
    home-manager, 
    ... 
  }@inputs: let 
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      office = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ 
          nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          nixos-hardware.nixosModules.common-cpu-amd-zenpower
          nixos-hardware.nixosModules.common-cpu-amd-pstate
          nixos-hardware.nixosModules.common-pc
          nixos-hardware.nixosModules.common-pc-ssd
          ./system/configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };

    homeConfigurations = {
      "nutsalhan87@office" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs rec {
          inherit system;
          config.allowUnfree = true;
        };
        modules = [ ./home/home.nix ];
        extraSpecialArgs = { 
          inherit nix-colorizer;
          fenix = fenix.packages.${system};
          stable-pkgs = import stable-nixpkgs rec {
            inherit system; 
            config.allowUnfree = true;
          };
        };
      };
    };
  };
}
