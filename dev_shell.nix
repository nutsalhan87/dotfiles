{
  outputs = { self, nixpkgs }: let 
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [ ];
    };
  };
}
