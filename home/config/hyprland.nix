{ pkgs, nix-colorizer, python-pkg, flameshot-pkg, ui-scale }: let
  oklch2h = oklch: let
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

  color_theme = let
    text.active = nix-colorizer.hex.to.oklch "#ffffff";
    text.inactive = nix-colorizer.oklch.darken text.active 0.5;
  in rec {
    bg = nix-colorizer.hex.to.oklch "#00111a";
    primary = nix-colorizer.hex.to.oklch "#013f5d";
    secondary = nix-colorizer.hex.to.oklch "#286223";
    alert = nix-colorizer.hex.to.oklch "#7e011c";
    inherit text;
  };
  opacity = 0.75;

  wallpaper_path = "~/.wallpaper-dark.jpg";
  keyboard_device = "platform::kbd_backlight";

  nemo = "${pkgs.nemo}/bin/nemo";
  alacritty = "${pkgs.alacritty}/bin/alacritty";
  python = "${python-pkg}/bin/python";
  flameshot = "${flameshot-pkg}/bin/flameshot";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";

in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    plugins = with pkgs; [ hyprlandPlugins.hy3 ];
    systemd.enable = false; # т.к. используется uwsm
    settings = {
      general = {
        layout = "hy3";
        gaps_out = 5;
        resize_on_border = true;
        "col.active_border" = "rgb(${builtins.substring 1 6 (nix-colorizer.oklch.to.hex color_theme.primary)})";
        "col.inactive_border" = "rgb(${builtins.substring 1 6 (nix-colorizer.oklch.to.hex color_theme.bg)})";
      };
      decoration = {
        rounding = 4;
        rounding_power = 4.0;
        blur = {
          enabled = true;
          noise = 0.15;
          passes = 3;
          popups = true;
        };
      };
      input = {
        kb_model = "pc104";
        kb_layout = "us,ru";
        kb_options = "grp:caps_toggle, grp_led:caps, compose:ralt";
        scroll_method = "2fg";
        touchpad = {
          natural_scroll = true;
        };
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_forever = true;
        workspace_swipe_direction_lock = false;
      };
      misc = {
        disable_hyprland_logo = true;
        font_family = "Iosevka";
        mouse_move_enables_dpms = true;
        animate_manual_resizes = true; 
        animate_mouse_windowdragging = true;

      };
      binds = {
        workspace_back_and_forth = true;
      };
      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
      plugin.hy3 = {
        tab_first_window = false;
        tabs = {
          from_top = true;
          radius = 4;
          height = 24;
          border_width = 1;
          text_center = false;
          text_font = "Iosevka";
          text_height = 11;
          text_padding = 5;
        } // (let
          palette = class: color: text: {
            "col.${class}" = oklch2h (color // { a = opacity; });
            "col.${class}.border" = oklch2h (color // { a = opacity / 1.5; });
            "col.${class}.text" = oklch2h text;
          };
        in with color_theme;
          builtins.foldl' (a: b: a // b) { } [
            (palette "active" primary text.active) 
            (palette "focused" (nix-colorizer.oklch.darken primary 0.2) text.active) 
            (palette "inactive" bg text.inactive) 
            (palette "urgent" alert text.active) 
            (palette "locked" (nix-colorizer.hex.to.oklch "#746801") text.active) 
          ]);
      };
      monitor = [ "eDP-1, preferred, 0x0, ${toString ui-scale}" ];
      windowrule = [
        "opacity 0.8, class:Alacritty"
        "opacity 0.85, class:code"
        "opacity 0.85, class:org.telegram.desktop"
        "opacity 1.0, class:org.telegram.desktop, initialTitle:Просмотр медиа"
        "noanim, class:org.telegram.desktop, initialTitle:Просмотр медиа"
        "noanim, class:flameshot"
      ];
      layerrule = [ 
        "blur, waybar" 
        "ignorezero, waybar"
        "blur, launcher" 
      ];
      animation = [
        "global, 1, 3, default"
        "layers, 1, 3, default, slide"
      ];
      bind = [
        "SUPER_SHIFT, Q, hy3:killactive"
        "SUPER, H, hy3:makegroup, h, ,"
        "SUPER, V, hy3:makegroup, v, ,"
        "SUPER, F, fullscreen, 0"
        "SUPER, W, hy3:changegroup, toggletab"
        "SUPER, E, hy3:changegroup, opposite"
        "SUPER, SPACE, hy3:togglefocuslayer, nowarp"
        "SUPER_SHIFT, SPACE, togglefloating,"
        "SUPER, P, hy3:changefocus, raise"
        "SUPER, C, hy3:changefocus, lower"
        "SUPER_SHIFT, R, forcerendererreload"
        "SUPER_SHIFT, C, exec, hyprctl reload"
        
        "SUPER, N, exec, ${nemo}"
        "SUPER, RETURN, exec, ${alacritty}"
        "SUPER, D, exec, tofi-drun"
        "SUPER, L, exec, loginctl lock-session"
        "SUPER, bracketright, exec, ${alacritty} -e ${python}"
        
        "SUPER, Left,  hy3:movefocus, l, , nowarp"
        "SUPER, Down,  hy3:movefocus, d, , nowarp"
        "SUPER, Up,    hy3:movefocus, u, , nowarp"
        "SUPER, Right, hy3:movefocus, r, , nowarp"

        "SUPER_SHIFT, Left, hy3:movewindow, l, once,"
        "SUPER_SHIFT, Down, hy3:movewindow, d, once,"
        "SUPER_SHIFT, Up, hy3:movewindow, u, once,"
        "SUPER_SHIFT, Right, hy3:movewindow, r, once,"

        ", XF86MonBrightnessDown, exec, ${brightnessctl} set 5%-"
        ", XF86MonBrightnessUp, exec, ${brightnessctl} set +5%"
        ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];
      binde = (builtins.foldl' (a: b: a ++ b) [ ] (
        builtins.map (
          i: let
            key = builtins.toString i;
            ws = if i == 0 then "10" else builtins.toString i;
          in [
            "SUPER, ${key}, workspace, ${ws}"
            "SUPER_SHIFT, ${key}, hy3:movetoworkspace, ${ws}, "
          ]
        ) (pkgs.lib.lists.range 0 9)
      ));
      bindr = [
        "SUPER, grave, exec, ${flameshot} gui -c -p /tmp/screenshot.png"
      ];
      bindlr = [
        ", Print, exec, ${flameshot} full -c -p /tmp/screenshot.png"
      ];
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
    extraConfig = ''
      bind = SUPER, R, submap, resize
      submap = resize
      binde = , right, resizeactive, 10 0
      binde = , left, resizeactive, -10 0
      binde = , up, resizeactive, 0 -10
      binde = , down, resizeactive, 0 10
      bind = , escape, submap, reset
      bind = , return, submap, reset
      submap = reset
    '';
  };
  services = {
    hyprpaper = {
      enable = true;
      settings = {
        preload = [ wallpaper_path ];
        wallpaper = [ ",${wallpaper_path}" ];
      };
    };
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 150;
            on-timeout = "${brightnessctl} -s set 10%";
            on-resume = "${brightnessctl} -r";
          }
          {
            timeout = 150;
            on-timeout = "${brightnessctl} -sd ${keyboard_device} set 0";
            on-resume = "${brightnessctl} -rd ${keyboard_device}";
          }
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
    hyprpolkitagent.enable = true;
  };
  programs = {
    hyprlock = {
      enable = true;
      settings = {
        general = {
          ignore_empty_input = true;
        };
        background = [
          {
            monitor = "";
            path = wallpaper_path;
            blur_passes = 3;
            noise = 0.05;
          }
        ];
        label = [
          {
            monitor = "";
            text = "cmd[update:1000] echo \"<span>$(date +%H:%M:%S)</span>\"";
            font_size = 92;
            font_family = "Oranienbaum";
            position = "0, 15%";
          }
        ];
        input-field = [
          {
            monitor = "";
            placeholder_text = "";
          }
        ];
      };
    };
    tofi = {
      enable = true;
      settings = {
        font = "Oranienbaum";
        text-color = nix-colorizer.oklch.to.hex color_theme.text.active;
        selection-color = nix-colorizer.oklch.to.hex (nix-colorizer.oklch.lighten color_theme.primary 0.2);
        prompt-text = "\"Run: \"";
        result-spacing = 25;
        width = "100%";
        height = "100%";
        background-color = nix-colorizer.oklch.to.hex (color_theme.bg // { a = opacity; });
        border-width = 0;
        outline-width = 0;
        padding-left = "35%";
        padding-top = "35%";
        drun-launch = true;
      };
    };
    waybar = {
      enable = true;
      systemd.enable = true;
      settings.mainBar = {
        layer = "top";
        position = "bottom";
        mode = "dock";
        fixed-center = false;

        modules-left = [ 
          "hyprland/workspaces"
          "hyprland/submap"
        ];
        modules-right = [
          "disk"
          "pulseaudio#out"
          "pulseaudio#mic"
          "backlight"
          "battery"
          "memory"
          "cpu"
          "temperature"
          "clock"
          "hyprland/language"
          "tray"
        ];
        
        "hyprland/workspaces" = {
          sort-by = "number";
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch workspace m-1";
          on-scroll-down = "hyprctl dispatch workspace m+1";
        };
        "hyprland/submap" = {
          tooltip = false;
        };
        "tray" = {
          spacing = 5;
        };
        "hyprland/language" = {
          format = "{}";
          format-en = "US";
          format-ru = "RU";
        };
        "clock" = {
          interval = 1;
          format = " {:L%a %d.%m.%Y %H:%M:%S}";
          locale = "ru_RU.UTF-8";
          tooltip = false;
        };
        "temperature" = {
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          format = " {temperatureC}°";
          tooltip = false;
          critical-threshold = 90;
        };
        "cpu" = {
          interval = 1;
          format = let 
            cores = 12;
            cores_idx = pkgs.lib.lists.range 1 (cores - 1);
            icons = builtins.foldl' (a: b: a + "{icon${toString b}}") "{icon0}" cores_idx;
          in
            " " + icons + " {usage}% {avg_frequency}GHz";
          format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
        };
        "memory" = {
          internal = 5;
          format = " {used:0.01f}GB/{total}GB {percentage}%";
          tooltip = false;
        };
        "battery" = {
          interval = 10;
          format = "{icon} {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          tooltip = false;
        };
        "backlight" = {
          format = "{icon} {percent}%";
          format-icons = [ "" "" ];
          on-scroll-up = "${brightnessctl} set +5%";
          on-scroll-down = "${brightnessctl} set 5%-";
          tooltip = false;
        };
        "pulseaudio#mic" = {
          format = "{format_source}";
          format-source = "";
          format-source-muted = "";
          on-click = "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          on-scroll-up = "";
          on-scroll-down = "";
          tooltip = false;
        };
        "pulseaudio#out" = {
          format = "{icon} {volume}%";
          format-icons = [ "" "" "" ];
          format-muted = " {volume}%";
          format-bluetooth = " {volume}%";
          scroll-step = 5.0;
          on-click = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          tooltip = false;
        };
        "disk" = {
          format = " {specific_used:0.1f}GB/{specific_total:1.0f}GB";
          unit = "GB";
          tooltip = false;
        };
      };
      style = ''
        window#waybar {
          font-size: 14px;
          font-family: "Iosevka", "Font Awesome 6 Free";
          color: ${oklch2h color_theme.text.active};
          background-color: transparent;
        }

        #waybar > box > box {
          margin: 2px;
          border-radius: 6px;
        }

        box.modules-right {
          padding: 2px;
          background-color: ${oklch2h (color_theme.bg // { a = opacity; })};
        }

        .module {
          margin: 0px 10px;
        }

        .module#workspaces {
          margin: 0;
        }

        #workspaces button {
          padding: 4px;
          margin: 0px 4px;
          border-radius: 4px;
          background-color: ${oklch2h (color_theme.bg // { a = opacity; })};
        }

        #workspaces button.active {
          background-color: ${oklch2h (color_theme.primary // { a = opacity; })};
        }

        #workspaces button.urgent {
          background-color: ${oklch2h (color_theme.alert // { a = opacity; })};
        }

        #submap.resize {
          padding: 0px 1em;
          border-radius: 4px;
          background-color: ${oklch2h (color_theme.secondary // { a = opacity; })}
        }
      '';
    };
  };
}