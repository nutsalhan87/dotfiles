{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    unstable-nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-colorizer.url = "github:nutsalhan87/nix-colorizer";
    
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    nixpkgs, 
    unstable-nixpkgs, 
    nix-colorizer, 
    nixos-hardware, 
    fenix, 
    home-manager, 
    ... 
  }@inputs: let 
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
        pkgs = import nixpkgs ({
          inherit system;
        } // (import ./nixpkgs.nix));
        modules = [ 
          ./home/home.nix
        ];
        extraSpecialArgs = {
          inherit nix-colorizer;
          fenix = fenix.packages.${system};
          unstable-pkgs = import unstable-nixpkgs ({
            inherit system; 
          } // (import ./nixpkgs.nix));
        };
      };
    };

    templates = {
      devShell = {
        path = ./templates/dev-shell;
        description = "Template flake with empty devShell";
      };
      crane = {
        path = ./templates/crane;
        description = "Template flake for development in rust";
      };
    };
  };
}
