{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    old-nixpkgs.url = "nixpkgs/nixos-24.05";
    nix-colorizer.url = "github:nutsalhan87/nix-colorizer";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, old-nixpkgs, nix-colorizer, nixos-hardware, fenix, home-manager, ... }@inputs: let 
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      lenovo = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ 
          nixos-hardware.nixosModules.lenovo-ideapad-15arh05
          ./system/configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };

    homeConfigurations = {
      "nutsalhan87@lenovo" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs rec {
          inherit system;
        };
        modules = [ ./home/home.nix ];
        extraSpecialArgs = { 
          inherit nix-colorizer;
          fenix = fenix.packages.${system};
          old-pkgs = import old-nixpkgs rec {
            inherit system;
          };
        };
      };
    };
  };
}
