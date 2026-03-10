{ pkgs, lib, config, nix-colorizer, ... }: let
  _hyprland = config.my._hyprland;
  color_theme = _hyprland.color_theme;
  oklch2rgba_hex = _hyprland.oklch2rgba_hex;
  hy3_palette = _hyprland.hy3_palette;

in {
  config = {
    services.darkman = let
      hyprctl-bin = "${pkgs.hyprland}/bin/hyprctl";
      hy3_dark_palette = hy3_palette color_theme.dark;
      hy3_light_palette = hy3_palette color_theme.light;
    in {
      enable = true;
      settings = { # bug: файл настроек не генерируется, если settings = {}, а без этого darkman падает
        dbusserver = true;
        portal = true;
      };
      darkModeScripts = {
        hyprland = pkgs.writers.writeBash "darken-hyprland" (''
          ${hyprctl-bin} hyprpaper wallpaper ",~/.wallpaper-dark.jpg"
          ${hyprctl-bin} keyword general:col.active_border "${oklch2rgba_hex color_theme.dark.primary}"
          ${hyprctl-bin} keyword general:col.inactive_border "${oklch2rgba_hex color_theme.dark.bg}" 
        '' 
          + "\n" 
          + (lib.strings.concatStringsSep "\n" (
              lib.attrsets.mapAttrsToList 
                (name: color: "${hyprctl-bin} keyword plugin:hy3:tabs:${name} \"${color}\"") 
                hy3_dark_palette
            ))
        );
      };
      lightModeScripts = {
        hyprland = pkgs.writers.writeBash "lighten-hyprland" (''
          ${hyprctl-bin} hyprpaper wallpaper ",~/.wallpaper-light.jpg"
          ${hyprctl-bin} keyword general:col.active_border "${oklch2rgba_hex color_theme.light.primary}"
          ${hyprctl-bin} keyword general:col.inactive_border "${oklch2rgba_hex color_theme.light.bg}" 
        ''
          + "\n" 
          + (lib.strings.concatStringsSep "\n" (
              lib.attrsets.mapAttrsToList 
                (name: color: "${hyprctl-bin} keyword plugin:hy3:tabs:${name} \"${color}\"") 
                hy3_light_palette
            ))
        );
      };
    };
    systemd.user.services = {
      darkman = {
        Unit = {
          After = "wayland-wm@hyprland.desktop.service";
        };
      };
    };
  };
}