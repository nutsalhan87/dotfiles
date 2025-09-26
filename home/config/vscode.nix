{ pkgs }:

{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vadimcn.vscode-lldb
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      llvm-vs-code-extensions.vscode-clangd
      mads-hartmann.bash-ide-vscode
      ms-azuretools.vscode-docker
      ms-toolsai.jupyter
      vscjava.vscode-java-pack
    ] ++ (with pkgs.vscode-extensions.ms-python; [ python debugpy vscode-pylance black-formatter ]);
  };
}
