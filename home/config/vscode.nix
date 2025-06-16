pkgs:
{
  enable = true;
  mutableExtensionsDir = false;
  extensions = with pkgs.vscode-extensions; [
    vadimcn.vscode-lldb
    jnoortheen.nix-ide
    rust-lang.rust-analyzer
    svelte.svelte-vscode
    llvm-vs-code-extensions.vscode-clangd
    mads-hartmann.bash-ide-vscode
    ms-azuretools.vscode-docker
    ms-toolsai.jupyter
    vscjava.vscode-java-pack
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "tauri-vscode";
      publisher = "tauri-apps";
      version = "0.2.9";
      sha256 = "sha256-ySfsmKAReKTLl6lHax2fnPu9paQ2pBSEMUoeGtGJelA=";
    }
    {
      name = "ng-template";
      publisher = "Angular";
      version = "18.2.0";
      sha256 = "sha256-rl04nqSSBMjZfPW8Y+UtFLFLDFd5FSxJs3S937mhDWE=";
    }
  ] ++ (with pkgs.vscode-extensions.ms-python; [ python debugpy vscode-pylance black-formatter ]);
}
