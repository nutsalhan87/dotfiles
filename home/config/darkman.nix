{ pkgs, ... }:

{
  services.darkman = let
    vscode-theme-setter = ../assets/vscode.py;
  in {
    enable = true;
    darkModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write \
          /org/gnome/desktop/interface/gtk-theme "'Fluent-Dark'"
        ${pkgs.dconf}/bin/dconf write \
          /org/gnome/desktop/interface/icon-theme "'Fluent-dark'"
        ${pkgs.dconf}/bin/dconf write \
          /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      '';
      vscode = ''
        ${pkgs.python3}/bin/python3 ${vscode-theme-setter} 'Default Dark Modern'
      '';
    };
    lightModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write \
          /org/gnome/desktop/interface/gtk-theme "'Fluent-Light'"
        ${pkgs.dconf}/bin/dconf write \
          /org/gnome/desktop/interface/icon-theme "'Fluent-light'"
        ${pkgs.dconf}/bin/dconf write \
          /org/gnome/desktop/interface/color-scheme "'prefer-light'"
      '';
      vscode = ''
        ${pkgs.python3}/bin/python3 ${vscode-theme-setter} 'Default Light Modern'
      '';
    };
  };
}