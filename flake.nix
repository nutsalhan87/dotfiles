{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    old-nixpkgs.url = "nixpkgs/nixos-22.11";
 
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, old-nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      lenovo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./system/configuration.nix ];
        specialArgs = { inherit inputs; };
      };
    };

    homeConfigurations = {
      "nutsalhan87@lenovo" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs rec {
          system = "x86_64-linux";
          
          overlays = [ (final: prev: {
          }) ];
        };
        modules = [ ./home/home.nix ];
        extraSpecialArgs = { 
          inherit inputs;
          old-pkgs = import old-nixpkgs rec {
            system = "x86_64-linux";
          }; 
        };
      };
    };
  };
}
