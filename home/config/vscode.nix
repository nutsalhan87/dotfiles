pkgs:
{
  enable = true;
  package = pkgs.vscodium;
  mutableExtensionsDir = false;
  extensions = with pkgs.vscode-extensions; [
    vadimcn.vscode-lldb
    jnoortheen.nix-ide
    ms-python.python
    rust-lang.rust-analyzer
    svelte.svelte-vscode
    llvm-vs-code-extensions.vscode-clangd
    mads-hartmann.bash-ide-vscode
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "tauri-vscode";
      publisher = "tauri-apps";
      version = "0.2.6";
      sha256 = "sha256-O9NxFemUgt9XmhL6BnNArkqbCNtHguSbvVOYwlT0zg4=";
    }
    {
      name = "ng-template";
      publisher = "Angular";
      version = "17.0.3";
      sha256 = "sha256-JEsffKLQO7fG/tGybNP5IMOegB4cn8nsTvgbhuyK58g=";
    }
  ];
}