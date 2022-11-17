{
  description = "A very basic flake";

  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;

    in {
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = with pkgs; [ dbus ];
        nativeBuildInputs = with pkgs; [ 
          # тут пакеты
        ];
     };
  };
}
