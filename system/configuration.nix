# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.auto-optimise-store = true;
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware = {
    nvidia.powerManagement = {
      enable = true;
      finegrained = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    acpilight.enable = true;
    bluetooth.enable = true;
    pulseaudio.enable = false;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
    kernel.sysctl."kernel.sysrq" = 502;
  };

  networking.hostName = "lenovo"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "ru_RU.UTF-8";
  };

  security.rtkit.enable = true;

  services = {
    logind.powerKey = "suspend";
    upower.enable = true;
    blueman.enable = true;

    postgresql = {
      enable = true;
      authentication = pkgs.lib.mkForce ''
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
      '';
    };

    xserver = {
      enable = true;
      xkb = {
        layout = "us,ru";
        options = "grp:caps_toggle, grp_led:caps, compose:ralt";      
      };
      displayManager.lightdm.enable = true;
      windowManager.i3.enable = true;
      screenSection = ''
        Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
        Option "TearFree" "true"
      '';
    };
    
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };

  environment = {
    sessionVariables = {
      LD_LIBRARY_PATH = let
        inputs = with pkgs; [
          xorg.libX11 xorg.libXcomposite xorg.libXcursor xorg.libXdamage xorg.libXext xorg.libXfixes
          xorg.libXi xorg.libXrandr xorg.libXrender xorg.libXtst xorg.libxcb xorg.xcbutilkeysyms xorg.libXxf86vm
        ];
      in builtins.foldl' (a: b: "${a}:${b}/lib") "/run/opengl-driver/lib:/run/opengl-driver-32/lib" inputs;
    };

    systemPackages = with pkgs; [
      vim
      wget
      unzip
    ];
  };

  fonts.packages = with pkgs; [
    iosevka-bin noto-fonts noto-fonts-emoji noto-fonts-cjk-sans liberation_ttf unscii
    source-code-pro source-sans-pro source-serif-pro roboto roboto-slab roboto-mono
    open-sans fira fira-code font-awesome
   ];

  users.users.nutsalhan87 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "adbusers" "libvirtd" "audio" "vboxusers" ];
    shell = pkgs.fish;
  };

  programs = {
    dconf.enable = true;
    fish.enable = true;
    adb.enable = true;
  };

  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    virtualbox.host.enable = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
