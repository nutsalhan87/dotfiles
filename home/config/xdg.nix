{ pkgs }:

{
  xdg = {
    enable = true;
    autostart = {
      enable = true;
      readOnly = true;
      entries = [ ];
    };
    desktopEntries = {
      poweroff = {
        name = "Power Off";
        exec = "poweroff";
      };
      reboot = {
        name = "Reboot";
        exec = "reboot";
      };
    };
    configFile = {
      kitty-dark-theme = {
        target = "kitty/dark-theme.auto.conf";
        source = pkgs.kitty-themes + /share/kitty-themes/themes/Alabaster_Dark.conf;
      };
      kitty-light-theme = {
        target = "kitty/light-theme.auto.conf";
        source = pkgs.kitty-themes + /share/kitty-themes/themes/Alabaster.conf;
      };
    };
    dataFile = {
      oranienbaum = {
        target = "fonts/Oranienbaum-Regular.ttf";
        source = ../assets/Oranienbaum-Regular.ttf;
      };
    };
    portal = {
      enable = pkgs.lib.mkForce true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
        darkman
      ];
    };
  };
}
