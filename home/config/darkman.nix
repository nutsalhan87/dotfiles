{ pkgs, ... }:

{
  services.darkman = {
    enable = true;
    settings = {
      dbusserver = true;
      portal = true;
    };
    scripts = {
      gtk-theme = ''
        if [ "$1" = "dark" ]; then
          ${pkgs.dconf}/bin/dconf write \
            /org/gnome/desktop/interface/gtk-theme "'Fluent-Dark'"
          ${pkgs.dconf}/bin/dconf write \
            /org/gnome/desktop/interface/icon-theme "'Fluent-dark'"
          ${pkgs.dconf}/bin/dconf write \
            /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
        elif [ "$1" = "light" ]; then
          ${pkgs.dconf}/bin/dconf write \
            /org/gnome/desktop/interface/gtk-theme "'Fluent-Light'"
          ${pkgs.dconf}/bin/dconf write \
            /org/gnome/desktop/interface/icon-theme "'Fluent-light'"
          ${pkgs.dconf}/bin/dconf write \
            /org/gnome/desktop/interface/color-scheme "'prefer-light'"
        fi
      '';
    };
  };
}