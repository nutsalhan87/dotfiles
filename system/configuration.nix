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
      powerManagement = {
        enable = true;
        finegrained = true;
      };
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

  networking = {
    hostName = "lenovo";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    wireless = {
      enable = false;
      iwd.enable = true;
    };
    firewall = {
      allowedUDPPorts = [ 53 67 1900 ];
      allowedTCPPorts = [ 53 ];
    };
    nftables.enable = true;
  };

  time.timeZone = "Europe/Moscow";

  i18n.extraLocaleSettings = {
    LC_TIME = "ru_RU.UTF-8";
  };

  security = {
    rtkit.enable = true;
    pam.services.hyprlock = {};
  }; 

  services = {
    logind.settings.Login.HandlePowerKey = "suspend";
    upower.enable = true;
    blueman.enable = true;
    gvfs.enable = true;

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
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      vim
      wget
      unzip
      git
      android-tools
    ];
  };

  fonts.packages = with pkgs; [
    iosevka-bin noto-fonts noto-fonts-color-emoji noto-fonts-cjk-sans liberation_ttf unscii
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
    hyprland = {
      enable = true;
      withUWSM = true;
    };
    virt-manager.enable = true;
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
    };
  };

  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
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
