{ pkgs, lib, config, nix-colorizer, ... }: let
  _hyprland = config.my._hyprland;
  color_theme = _hyprland.color_theme;
  oklch2rgba_hex = _hyprland.oklch2rgba_hex;
  hy3_colors = _hyprland.hy3_colors;

in {
  config = {
    services.darkman = let
      hyprctl-bin = "${pkgs.hyprland}/bin/hyprctl";
      hy3_dark_colors = hy3_colors color_theme.dark;
      hy3_light_colors = hy3_colors color_theme.light;
      awww-bin = "${pkgs.awww}/bin/awww";
    in {
      scripts.hyprland = ''
        if [ "$1" = "dark" ]; then
          ${awww-bin} img -t fade --transition-duration 1 --transition-fps 60 ~/.wallpaper-dark.jpg
          ${hyprctl-bin} keyword general:col.active_border "${oklch2rgba_hex color_theme.dark.primary}"
          ${hyprctl-bin} keyword general:col.inactive_border "${oklch2rgba_hex color_theme.dark.bg}"
          ${lib.strings.concatStringsSep "\n" (
            lib.attrsets.mapAttrsToList 
              (name: color: "${hyprctl-bin} keyword plugin:hy3:tabs:colors:${name} \"${color}\"") 
              hy3_dark_colors
          )}
        elif [ "$1" = "light" ]; then
          ${awww-bin} img -t fade --transition-duration 1 --transition-fps 60 ~/.wallpaper-light.jpg
          ${hyprctl-bin} keyword general:col.active_border "${oklch2rgba_hex color_theme.light.primary}"
          ${hyprctl-bin} keyword general:col.inactive_border "${oklch2rgba_hex color_theme.light.bg}"
          ${lib.strings.concatStringsSep "\n" (
            lib.attrsets.mapAttrsToList 
              (name: color: "${hyprctl-bin} keyword plugin:hy3:tabs:colors:${name} \"${color}\"") 
              hy3_light_colors
          )}
        fi
      '';
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