{ pkgs, nix-colorizer, python-pkg, ui-scale }: 
let
  color_theme = let
    text.active = "#ffffff";
    text.active' = nix-colorizer.hexToOklch text.active;
    text.neutral = nix-colorizer.oklchToHex (nix-colorizer.darken text.active' 25);
    text.inactive = nix-colorizer.oklchToHex (nix-colorizer.darken text.active' 50);
  in rec {
    bg = "#081014";
    primary = "#213E50";
    secondary = "#375e33";
    alert = "#5e3333";
    inherit text;
  };
  
  nemo = "${pkgs.nemo}/bin/nemo";
  alacritty = "${pkgs.alacritty}/bin/alacritty";
  python = "${python-pkg}/bin/python";
  dmenu = "${pkgs.dmenu}/bin/dmenu_run";
  i3lock = "${pkgs.i3lock}/bin/i3lock";
  flameshot = "${pkgs.flameshot}/bin/flameshot";
  i3status-rust = "${pkgs.i3status-rust}/bin/i3status-rs";
  i3-nagbar = "${pkgs.i3}/bin/i3-nagbar";
  np-applet = "${pkgs.networkmanagerapplet}/bin/nm-applet";
  blueman-applet = "${pkgs.blueman}/bin/blueman-applet";
  feh = "${pkgs.feh}/bin/feh";
  xbacklight = "${pkgs.acpilight}/bin/xbacklight";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
in

{
  i3 =
    let
      mod = "Mod4";
    in
    {
      enable = true;
      config = {
        colors = let
          palette = bg: text: let 
            bg_oklch = nix-colorizer.hexToOklch bg;
            bg_lighter = nix-colorizer.lighten bg_oklch 10;
            bg_colorful = with bg_lighter; {
              inherit L h;
              C = C + 0.05;
            }; 
          in {
            background = bg;
            border = bg;
            childBorder = bg;
            indicator = nix-colorizer.oklchToHex bg_colorful;
            inherit text;
          };
        in
        with color_theme; {
          background = bg;
          focused = palette primary text.active;
          focusedInactive = palette "#5f676a" text.active; # parent container color
          unfocused = palette bg text.inactive;
          urgent = palette alert text.active;
        };

        floating = {
          modifier = mod;
          titlebar = false;
        };
        fonts = {
          names = [ "Iosevka" ];
          size = 11.0;
        };
        gaps = {
          inner = builtins.floor (5 * ui-scale);
          smartGaps = true;
        };
        window = {
          titlebar = false;
          hideEdgeBorders = "both";
        };
        workspaceAutoBackAndForth = true;
        defaultWorkspace = "workspace number 1";

        modifier = mod;
        keybindings =
          let
            refresh_i3status = "killall -SIGUSR1 i3status-rs";
          in
          {
            "${mod}+Shift+q" = "kill";
            "${mod}+n" = "exec ${nemo}";
            "${mod}+h" = "split h";
            "${mod}+v" = "split v";
            "${mod}+f" = "fullscreen toggle";
            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+e" = "layout toggle split";
            "${mod}+space" = "focus mode_toggle";
            "${mod}+Shift+space" = "floating toggle";
            "${mod}+p" = "focus parent";
            "${mod}+c" = "focus child";
            "${mod}+Shift+c" = "reload"; # reload conf file
            "${mod}+Shift+r" = "restart"; # restart i3
            "${mod}+Shift+e" = "exec \"${i3-nagbar} -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'\"";
            "${mod}+r" = "mode resize";

            "${mod}+Return" = "exec ${alacritty}";
            "${mod}+d" = "exec ${dmenu}";
            "${mod}+l" = "exec \"${i3lock} -e -i ~/.wallpaper.png -t\"";
            "${mod}+bracketright" = "exec \"${alacritty} -e ${python}\"";
            "--release ${mod}+grave" = "exec \"${flameshot} gui -c -p /tmp/screenshot.png\"";
            "--release Print" = "exec \"${flameshot} full -c -p /tmp/screenshot.png\"";

            "${mod}+Left" = "focus left";
            "${mod}+Down" = "focus down";
            "${mod}+Up" = "focus up";
            "${mod}+Right" = "focus right";

            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Down" = "move down";
            "${mod}+Shift+Up" = "move up";
            "${mod}+Shift+Right" = "move right";

            "XF86MonBrightnessDown" = "exec --no-startup-id ${xbacklight} -dec 5";
            "XF86MonBrightnessUp" = "exec --no-startup-id ${xbacklight} -inc 5";
            "XF86AudioRaiseVolume" = "exec --no-startup-id ${pactl} set-sink-volume @DEFAULT_SINK@ +5% && ${refresh_i3status}";
            "XF86AudioLowerVolume" = "exec --no-startup-id ${pactl} set-sink-volume @DEFAULT_SINK@ -5% && ${refresh_i3status}";
            "XF86AudioMute" = "exec --no-startup-id ${pactl} set-sink-mute @DEFAULT_SINK@ toggle && ${refresh_i3status}";
            "XF86AudioMicMute" = "exec --no-startup-id ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle && ${refresh_i3status}";

          }
          // (builtins.foldl' (a: b: a // b) { } (
            builtins.map (
              i:
              let
                key = builtins.toString i;
                ws = if i == 0 then "10" else builtins.toString i;
              in
              {
                "${mod}+${key}" = "workspace number ${ws}";
                "${mod}+Shift+${key}" = "move container to workspace number ${ws}";
              }
            ) (pkgs.lib.lists.range 0 9)
          ));

        modes = {
          resize = {
            Left = "resize shrink width 10 px or 10 ppt";
            Down = "resize grow height 10 px or 10 ppt";
            Up = "resize shrink height 10 px or 10 ppt";
            Right = "resize grow width 10 px or 10 ppt";
            Return = "mode default";
            Escape = "mode default";
          };
        };

        startup = [
          {
            command = "${feh} --no-fehbg --bg-scale ~/.wallpaper.png";
            always = true;
          }
        ];

        bars =
          let
            palette = bg: text: {
              border = bg;
              background = bg;
              inherit text;
            };
          in
          [
            {
              colors = with color_theme; {
                background = bg;
                focusedWorkspace = palette primary text.active;
                activeWorkspace = palette primary text.active;
                inactiveWorkspace = palette bg text.inactive;
                urgentWorkspace = palette alert text.active;
                bindingMode = palette secondary text.active;
              };
              fonts = {
                names = [
                  "Iosevka"
                  "Font Awesome 6 Free"
                ];
                size = 11.0;
              };
              mode = "dock";
              position = "bottom";
              statusCommand = "${i3status-rust} ~/.config/i3status-rust/config-default.toml";
              trayOutput = "primary"; # On which output (monitor) the icons should be displayed
              workspaceButtons = true; # Whether workspace buttons should be shown or not
              workspaceNumbers = true; # Whether workspace numbers should be displayed within the workspace buttons
            }
          ];
      };
    };

  i3status-rust = {
    enable = true;
    bars = {
      default = {
        theme = "plain";
        settings.theme.overrides = with color_theme; {
          idle_bg = bg;
          idle_fg = text.neutral;
          warning_bg = bg;
          warning_fg = text.neutral;
          info_bg = bg;
          info_fg = text.neutral;
          good_bg = bg;
          good_fg = text.neutral;
          critical_bg = bg;
          critical_fg = text.neutral;
          separator_bg = bg;
          separator_fg = nix-colorizer.oklchToHex (nix-colorizer.darken (nix-colorizer.hexToOklch text.inactive) 10);
          separator = "  ";
        };
        icons = "awesome6";
        blocks = [
          {
            block = "disk_space";
            path = "/";
            info_type = "used";
            format = "  $used/$total";
          }
          {
            block = "sound";
            max_vol = 100;
            step_width = 5;
            click = [
              { button = "right"; }
              {
                button = "left";
                action = "toggle_mute";
              }
            ];
          }
          {
            block = "sound";
            device_kind = "source";
            format = "$icon";
            click = [
              { button = "up"; }
              { button = "down"; }
              { button = "right"; }
              { 
                button = "left";
                action = "toggle_mute";
              }
            ];
          }
          {
            block = "backlight";
            format = "  $brightness ";
          }
          {
            block = "battery";
            driver = "upower";
            format = " $icon $percentage ";
            full_format = " $icon $percentage ";
          }
          {
            block = "memory";
            format = " $icon $mem_used.eng(w:4)/$mem_total.eng(w:3) $mem_used_percents ";
            icons_overrides.memory_mem = "";
          }
          {
            block = "cpu";
            format = " $icon $barchart $utilization $frequency.eng(w:3) ";
            interval = 1;
            icons_overrides.cpu = "";
          }
          {
            block = "temperature";
            chip = "k10temp-pci-00c3";
            format = " $icon $average ";
          }
          {
            block = "time";
            interval = 1;
            format = " $icon $timestamp.datetime(f:'%a %d.%m.%Y %H:%M:%S', l:ru_RU) ";
          }
        ];
      };
    };
  };
}
