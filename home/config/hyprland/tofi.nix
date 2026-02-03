{ pkgs, lib, config, nix-colorizer, ... }: let
  _hyprland = config.my._hyprland;
  color_theme = _hyprland.color_theme;
  opacity = _hyprland.opacity;

in {
  config = {
    programs.tofi = {
      enable = true;
      settings = {
        font = "Oranienbaum";
        text-color = nix-colorizer.oklch.to.hex color_theme.dark.text.active;
        selection-color = nix-colorizer.oklch.to.hex (nix-colorizer.oklch.lighten color_theme.dark.primary 0.2);
        prompt-text = "\"Run: \"";
        result-spacing = 25;
        width = "100%";
        height = "100%";
        background-color = nix-colorizer.oklch.to.hex (color_theme.dark.bg // { a = opacity; });
        border-width = 0;
        outline-width = 0;
        padding-left = "35%";
        padding-top = "35%";
        drun-launch = true;
      };
    };
  };
}