{ pkgs, lib, config, nix-colorizer, ... }: let
  _hyprland = config.my._hyprland;
  wallpaper_path = _hyprland.wallpaper_path;

in {
  config = lib.mkMerge [
    {
      services = {
        hyprpaper = {
          enable = true;
          settings = {
            wallpaper = [ 
              {
                monitor = "";
                path = wallpaper_path.dark;
              }
            ];
            splash = false;
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
                timeout = 600;
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
          timeout = 630;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    })
  ];
}