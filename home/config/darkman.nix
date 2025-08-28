{ pkgs, python-pkg }:

{
  services.darkman = let
    python-bin = pkgs.lib.getExe python-pkg;
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
        ${python-bin} ${vscode-theme-setter} 'Default Dark Modern'
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
        ${python-bin} ${vscode-theme-setter} 'Default Light Modern'
      '';
    };
  };

  systemd.user.services = {
    darkman = {
      Unit = {
        After = "wayland-wm@Hyprland.service";
      };
    };
  };
}