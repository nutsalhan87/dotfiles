{ pkgs, lib, config, nix-colorizer, ... }: let
  _hyprland = config.my._hyprland;
  color_theme = _hyprland.color_theme;
  gaps = _hyprland.gaps;
  oklch2rgba = _hyprland.oklch2rgba;
  wpctl = _hyprland.wpctl;
  opacity = _hyprland.opacity;

  waybar-style = let
    dark-colors = with color_theme.dark; {
      text_color = "${oklch2rgba text.active}";
      text_color_contrast = "${oklch2rgba text.active}";
      bg_color = "${oklch2rgba (bg // { a = opacity; })}";
      primary_color = "${oklch2rgba (primary // { a = opacity; })}";
      alert_color = "${oklch2rgba (alert // { a = opacity; })}";
      secondary_color = "${oklch2rgba (secondary // { a = opacity; })}";
    };
    light-colors = with color_theme.light; {
      text_color = "${oklch2rgba text.inactive}";
      text_color_contrast = "${oklch2rgba text.active}";
      bg_color = "${oklch2rgba (bg // { a = opacity; })}";
      primary_color = "${oklch2rgba (primary // { a = opacity; })}";
      alert_color = "${oklch2rgba (alert // { a = opacity; })}";
      secondary_color = "${oklch2rgba (secondary // { a = opacity; })}";
    };
    style = colors: with colors; ''
      window#waybar {
        font-size: 14px;
        font-family: "Iosevka", "Font Awesome 7 Free";
        color: ${text_color};
        background-color: transparent;
      }

      box.horizontal {
        min-height: 2.25em;
      }

      #waybar > box > box {
        margin: 0px ${toString gaps}px ${toString gaps}px;
      }

      .module {
        padding: 0 1em;
        margin: 0 calc(${toString gaps}px / 2);
        border-radius: 4px;
      }

      widget:first-child > .module {
        margin-left: 0;
      }

      widget:last-child > .module {
        margin-right: 0;
      }

      .modules-right .module {
        background-color: ${bg_color};
      }

      .module#workspaces {
        padding: unset;
      }

      .module#workspaces button {
        padding: 0 calc(1em / 3);
        margin: 0 calc(${toString gaps}px / 2);
        border-radius: 4px;
        color: ${text_color};
        background-color: ${bg_color};
      }

      .module#workspaces button:first-child {
        margin-left: 0;
      }

      .module#workspaces button.active {
        color: ${text_color_contrast};
        background-color: ${primary_color};
      }

      .module#workspaces button.urgent {
        color: ${text_color_contrast};
        background-color: ${alert_color};
      }

      .module#submap.resize {
        color: ${text_color_contrast};
        background-color: ${secondary_color};
      }
    ''; # TODO: попробовать напрямую oklch — css вроде бы поддерживает
  in {
    dark = style dark-colors;
    light = style light-colors;
  };

in {
  config = lib.mkMerge [
    {
      programs.waybar = {
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
            "custom/openvpn-office"
            "custom/darkman"
            "disk"
            "pulseaudio#out"
            "memory"
            "cpu"
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
          "cpu" = {
            interval = 1;
            format = let 
              cores = 16;
              cores_idx = lib.lists.range 1 (cores - 1);
              icons = builtins.foldl' (a: b: a + "{icon${toString b}}") "{icon0}" cores_idx;
            in
              " " + icons + " {usage}% {avg_frequency:0.01f}GHz";
            format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
          };
          "memory" = {
            internal = 5;
            format = " {used:0.01f}GB/{total}GB {percentage}%";
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
            unit = "GiB";
            tooltip = false;
          };
          "custom/darkman" = let
            dark-icon = "";
            light-icon = "";  
          in {
            escape = true;
            interval = 1;
            exec = "sh -c 'if [ $(darkman get) = \"dark\" ]; then echo \"${dark-icon}\"; else echo \"${light-icon}\"; fi'";
            tooltip = false;
            on-click = "darkman toggle";
          };
          "custom/openvpn-office" = let
            active-icon = "";
            inactive-icon = "";
          in {
            interval = 1;
            exec = "sh -c 'if systemctl is-active openvpn-office.service 1>/dev/null; then echo  ${active-icon}; else echo  ${inactive-icon}; fi'";
            tooltip = false;
            on-click = "sh -c 'if systemctl is-active openvpn-office.service; then sudo systemctl stop openvpn-office.service; else sudo systemctl start openvpn-office.service; fi'";
          };
        };
        style = waybar-style.dark;
      };
      xdg.configFile = {
        waybar-style-light = {
          target = "waybar/style-light.css";
          text = waybar-style.light;
        };
        waybar-style-dark = {
          target = "waybar/style-dark.css";
          text = waybar-style.dark;
        };
      };
    }
    (lib.mkIf config.my.mic {
      programs.waybar.settings.mainBar = {
        modules-right = lib.mkBefore [ "pulseaudio#mic" ];
        "pulseaudio#mic" = {
          format = "{format_source}";
          format-source = "";
          format-source-muted = "";
          on-click = "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          on-scroll-up = "";
          on-scroll-down = "";
          tooltip = false;
        };
      };
    })
  ];
}