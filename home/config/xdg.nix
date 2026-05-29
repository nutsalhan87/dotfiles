{ pkgs, lib, config, ... }:

{
  config = {
    home.preferXdgDirectories = true;
    xdg = {
      enable = true;
      autostart = {
        enable = true;
        readOnly = true;
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
        hibernate = {
          name = "Hibernate";
          exec = "systemctl hibernate";
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
        pnpm_home = {
          target = "pnpm/.keep";
          text = "";
        };
      };
      portal = {
        enable = lib.mkForce true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
          darkman
        ];
      };
    };
  };
}
