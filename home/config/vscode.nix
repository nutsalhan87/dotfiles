{ pkgs, ... }:

{
  config.programs.vscode = {
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
      redhat.java vscjava.vscode-java-debug vscjava.vscode-java-test vscjava.vscode-java-dependency vscjava.vscode-maven vscjava.vscode-maven 
      ms-vscode.makefile-tools
      tamasfe.even-better-toml
      bierner.markdown-mermaid # до vscode 1.121
    ] ++ (with pkgs.vscode-extensions.ms-python; [ python debugpy vscode-pylance black-formatter ]);
  };
}
