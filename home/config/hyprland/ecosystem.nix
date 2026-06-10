{ pkgs, lib, config, nix-colorizer, ... }: let
  _hyprland = config.my._hyprland;
  wallpaper_path = _hyprland.wallpaper_path;
  idle_lock_timeout = _hyprland.idle_lock_timeout;
  keyboard_led_device = _hyprland.keyboard_led_device;
  brightnessctl = _hyprland.brightnessctl;

in {
  config = lib.mkMerge [
    {
      services = {
        awww.enable = true;
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
                timeout = idle_lock_timeout;
                on-timeout = "loginctl lock-session";
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
                path = wallpaper_path.dark;
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
              {
                monitor = "";
                text = "cmd[update:17] echo \"<span>$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')</span>\"";
                font_size = 24;
                font_family = "Oranienbaum";
                position = "-2.5%, 2.5%";
                halign = "right";
                valign = "bottom";
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
      };
    }
    (lib.mkIf config.my.dpms {
      services.hypridle.settings.listener = [
        {
          timeout = idle_lock_timeout * 1.1;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    })
    (lib.mkIf config.my.keyboard_led {
      services.hypridle.settings.listener = [
        {
          timeout = idle_lock_timeout / 2.0;
          on-timeout = "${brightnessctl} -sd ${keyboard_led_device} set 0";
          on-resume = "${brightnessctl} -rd ${keyboard_led_device}";
        }
      ];
    })
    (lib.mkIf config.my.screen_brightness {
      services.hypridle.settings.listener = [
        {
          timeout = idle_lock_timeout / 2.0;
          on-timeout = "${brightnessctl} -s set 10%";
          on-resume = "${brightnessctl} -r";
        }
      ];
    })
  ];
}