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
    nvidia = {
      open = false;
      powerManagement.enable = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    acpilight.enable = true;
    bluetooth.enable = true;
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
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "office"; # Define your hostname.
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

  security = {
    rtkit.enable = true;
    pam.services.hyprlock = {};
    sudo.extraRules = [
      {
        groups = [ "wheel" ];
        commands = map (ctl-cmd: { 
          command = "/run/current-system/sw/bin/systemctl ${ctl-cmd} openvpn-office.service";
          options = [ "NOPASSWD" ]; 
        }) [ "start" "stop" "is-active" ];
      }
    ];
  }; 

  services = {
    logind.settings.Login.HandlePowerKey = "suspend";
    upower.enable = true;
    blueman.enable = true;

    postgresql = {
      enable = true;
      authentication = pkgs.lib.mkForce ''
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
      '';
    };

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
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
    pulseaudio.enable = false;

    openvpn.servers.office = {
      config = '' config /root/.config/openvpn/office.ovpn '';
      authUserPass = "/root/.config/openvpn/office.auth";
      updateResolvConf = true;
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
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      vim
      wget
      unzip
      git
    ];
  };

  fonts.packages = with pkgs; [
    iosevka-bin noto-fonts noto-fonts-emoji noto-fonts-cjk-sans liberation_ttf unscii
    source-code-pro source-sans-pro source-serif-pro roboto roboto-slab roboto-mono
    open-sans fira fira-code font-awesome
  ];

  users = {
    users.nutsalhan87 = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "adbusers" "libvirtd" "audio" ];
      shell = pkgs.fish;
    };
    groups.libvirtd = {};
  };

  programs = {
    dconf.enable = true;
    fish.enable = true;
    adb.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
    };
    virt-manager.enable = true;
  };

  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

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
  system.stateVersion = "25.05"; # Did you read the comment?
}
