{ pkgs, lib, config, nix-colorizer, ... }: let
  oklch2rgba = oklch: let
    round = x: let 
      ceiled = builtins.ceil x; 
      floored = builtins.floor x; 
    in 
      if (x - floored) >= (ceiled - x) then ceiled else floored;
    clamp = x: a: b: 
      if x < a then a 
      else if x > b then b 
      else x;
    srgb = nix-colorizer.oklch.to.srgb oklch;
    srgb' = builtins.mapAttrs (channel: value: clamp value 0.0 1.0) srgb;
    srgb'' = with srgb'; {
      r = toString (round (r * 255.0));
      g = toString (round (g * 255.0));
      b = toString (round (b * 255.0));
      a = toString a;
    };
  in with srgb'';
    "rgba(${r}, ${g}, ${b}, ${a})";

  oklch2rgba_hex = oklch: if oklch.a == 1.0
    then "rgb(${builtins.substring 1 6 (nix-colorizer.oklch.to.hex oklch)})"
    else "rgba(${builtins.substring 1 8 (nix-colorizer.oklch.to.hex oklch)})";

  color_theme = {
    dark = rec {
      bg = nix-colorizer.hex.to.oklch "#112630";
      primary = nix-colorizer.hex.to.oklch "#013f5d";
      secondary = nix-colorizer.hex.to.oklch "#286223";
      alert = nix-colorizer.hex.to.oklch "#7e011c";
      text.active = nix-colorizer.hex.to.oklch "#ffffff";
      text.inactive = text.active // { L = text.active.L * 0.75; };
    };
    light = rec {
      bg = nix-colorizer.hex.to.oklch "#dae9f2";
      primary = nix-colorizer.hex.to.oklch "#036896";
      secondary = nix-colorizer.hex.to.oklch "#588b53";
      alert = nix-colorizer.hex.to.oklch "#c22e3e";
      text.active = nix-colorizer.hex.to.oklch "#ffffff";
      text.inactive = text.active // { L = text.active.L * 0.2; };
    };
  };
  gaps = 5;
  opacity = 0.75;

  hy3_palette = theme: let
    palette = class: color: text: {
      "col.${class}" = oklch2rgba (color // { a = opacity; });
      "col.${class}.border" = oklch2rgba (theme.bg // { a = opacity; });
      "col.${class}.text" = oklch2rgba text;
    };
  in with theme;
    builtins.foldl' (a: b: a // b) { } [
      (palette "active" primary text.active) 
      (palette "focused" (nix-colorizer.oklch.darken primary 0.2) text.active) 
      (palette "inactive" bg text.inactive) 
      (palette "urgent" alert text.active) 
      (palette "locked" (nix-colorizer.hex.to.oklch "#746801") text.active) 
    ];

  wallpaper_path = {
    dark = "~/.wallpaper-dark.jpg"; 
    light = "~/.wallpaper-light.jpg"; 
  };

  idle_lock_timeout = 300;
  keyboard_led_device = "platform::kbd_backlight";

in {
  imports = [
    ./hyprland.nix
    ./ecosystem.nix
    ./waybar.nix
    ./tofi.nix
    ./darkman.nix
  ];

  options.my = {
    dpms = lib.mkEnableOption "DPMS";
    keyboard_led = lib.mkEnableOption "Is possible to change keyboard led"; 
    screen_brightness = lib.mkEnableOption "Is possible to change screen brightness"; 
    mic = lib.mkEnableOption "mic";
    card-path = lib.mkOption {
      type = lib.types.pathWith { inStore = false; absolute = true; };
    };
    is-nvidia = lib.mkEnableOption "Hyprland Nvidia support";
    battery = lib.mkEnableOption "Battery presence";
    _hyprland = {
      color_theme = lib.mkAnything color_theme;
      opacity = lib.mkAnything opacity;
      gaps = lib.mkAnything gaps;
      hy3_palette = lib.mkAnything hy3_palette;
      oklch2rgba = lib.mkAnything oklch2rgba;
      oklch2rgba_hex = lib.mkAnything oklch2rgba_hex;
      wallpaper_path = lib.mkAnything wallpaper_path;
      idle_lock_timeout = lib.mkAnything idle_lock_timeout;
      keyboard_led_device = lib.mkAnything keyboard_led_device;
    };
  };

  config = lib.mkMerge [
    { 
      systemd.user.tmpfiles.rules = [
        "L %t/card  - - - -   ${config.my.card-path}"
      ];
      xdg = {
        configFile= {
          uwsm-env-hyprland = {
            executable = true;
            target = "uwsm/env-hyprland";
            text = ''
              export AQ_DRM_DEVICES="$XDG_RUNTIME_DIR/card"
            '';
          };
        };
        portal.config.hyprland = {
          default = [ "hyprland" "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
        };
      };
    }
    (lib.mkIf config.my.is-nvidia {
      home.packages = [ pkgs.egl-wayland ];
      xdg.configFile.uwsm-env-hyprland.text = lib.mkAfter ''
        export LIBVA_DRIVER_NAME=nvidia
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
      '';
    })
  ];
}
