{ pkgs, lib, config, nix-colorizer, ... }: let
  _hyprland = config.my._hyprland;
  color_theme = _hyprland.color_theme;
  gaps = _hyprland.gaps;
  opacity = _hyprland.opacity;
  oklch2rgba = _hyprland.oklch2rgba;
  oklch2rgba_hex = _hyprland.oklch2rgba_hex;
  hy3_palette = _hyprland.hy3_palette;

  nemo = "${pkgs.nemo}/bin/nemo";
  kitty = "${pkgs.kitty}/bin/kitty";
  python = "${pkgs.python3}/bin/python";
  flameshot = "${pkgs.flameshot}/bin/flameshot";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";

in {
  options.my = {
    _hyprland.wpctl = lib.mkAnything wpctl;
  };

  config = lib.mkMerge [
    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        plugins = with pkgs; [ hyprlandPlugins.hy3 ];
        systemd.enable = false; # т.к. используется uwsm
        settings = {
          general = {
            layout = "hy3";
            border_size = 2;
            gaps_out = gaps;
            gaps_in = gaps / 2;
            resize_on_border = true;
            "col.active_border" = oklch2rgba_hex color_theme.dark.primary;
            "col.inactive_border" = oklch2rgba_hex color_theme.dark.bg;
          };
          decoration = {
            rounding = 4;
            rounding_power = 4.0;
            blur = {
              enabled = true;
              noise = 0.15;
              passes = 4;
              popups = true;
            };
          };
          input = {
            kb_model = "pc104";
            kb_layout = "us,ru";
            kb_options = "grp:caps_toggle, compose:ralt";
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
              padding = gaps;
              border_width = 2;
              text_center = false;
              text_font = "Iosevka";
              text_height = 11;
              text_padding = 5;
            } // (hy3_palette color_theme.dark);
          };
          windowrule = [
            "match:class kitty, opacity 0.8"
            "match:class code, opacity 0.85"
            "match:class Zulip, opacity 0.85"
            "match:class thunderbird, opacity 0.85"
            "match:class v2rayN, opacity 0.85"
            "match:class org.telegram.desktop, opacity 0.85"
            "match:class org.telegram.desktop, match:initial_title Просмотр медиа, opacity 1.0"
            "match:class org.telegram.desktop, match:initial_title Просмотр медиа, no_anim on"
            "match:title flameshot, no_anim on"
          ];
          layerrule = [ 
            "blur on, match:namespace waybar" 
            "ignore_alpha 0, match:namespace waybar"
            "blur on, match:namespace launcher" 
          ];
          animation = [
            "global, 1, 3, default"
            "layers, 1, 3, default, slide"
          ];
          bind = [
            "SUPER_SHIFT, Q, hy3:killactive"
            "SUPER, H, hy3:makegroup, h, ,"
            "SUPER, V, hy3:makegroup, v, ,"
            "SUPER, F, fullscreenstate, 2, -1"
            "SUPER_SHIFT, F, fullscreenstate, -1, 2"
            "SUPER, W, hy3:changegroup, toggletab"
            "SUPER, E, hy3:changegroup, opposite"
            "SUPER, SPACE, hy3:togglefocuslayer, nowarp"
            "SUPER_SHIFT, SPACE, togglefloating,"
            "SUPER, P, hy3:changefocus, raise"
            "SUPER, C, hy3:changefocus, lower"
            "SUPER_SHIFT, R, forcerendererreload"
            "SUPER_SHIFT, C, exec, hyprctl reload"
            
            "SUPER, N, exec, uwsm app -- ${nemo}"
            "SUPER, RETURN, exec, uwsm app -- ${kitty}"
            "SUPER, D, exec, uwsm app -- tofi-drun"
            "SUPER, L, exec, loginctl lock-session"
            "SUPER, bracketright, exec, uwsm app -- ${kitty} -e ${python}"
            
            "SUPER, Left,  hy3:movefocus, l, , nowarp"
            "SUPER, Down,  hy3:movefocus, d, , nowarp"
            "SUPER, Up,    hy3:movefocus, u, , nowarp"
            "SUPER, Right, hy3:movefocus, r, , nowarp"

            "SUPER_SHIFT, Left, hy3:movewindow, l, once,"
            "SUPER_SHIFT, Down, hy3:movewindow, d, once,"
            "SUPER_SHIFT, Up, hy3:movewindow, u, once,"
            "SUPER_SHIFT, Right, hy3:movewindow, r, once,"

            ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"

            "ALT, F9, pass, class:^(com\.obsproject\.Studio)$"
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
            ) (lib.lists.range 0 9)
          )) ++ [
            "SUPER, TAB, workspace, e+1"
            "SUPER_SHIFT, TAB, workspace, e-1"
          ];
          bindr = [
            "SUPER, grave, exec, uwsm app -- ${flameshot} gui -c -p /tmp/screenshot.png"
          ];
          bindlr = [
            ", Print, exec, uwsm app -- ${flameshot} full -c -p /tmp/screenshot.png"
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
    }
    (lib.mkIf config.my.mic {
      wayland.windowManager.hyprland.settings.bind = [
        ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];
    })
  ];
}