# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings.auto-optimise-store = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.prime = {
    offload.enable = true;
    amdgpuBusId = "PCI:5:0:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  hardware.acpilight.enable = true;
  hardware.bluetooth.enable = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;

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

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.

  security.rtkit.enable = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.upower.enable = true;
  services.tlp.enable = true;
  services.fstrim.enable = true;
  services.xserver.libinput.enable = true;
  services.blueman.enable = true;

  #MY SHIT
  services.xserver.libinput.touchpad.naturalScrolling = true; 
  services.postgresql.enable = true;
  services.postgresql.authentication = pkgs.lib.mkForce ''
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            trust
  '';

  environment.shellAliases = {
    bsave = "sudo cpupower frequency-set -g powersave";
    bstd = "sudo cpupower frequency-set -g schedutil";
  };

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
    EDITOR = "nano";
    TERMINAL = "alacritty";
    JAVA_TOOL_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
    LD_LIBRARY_PATH = let
      inputs = with pkgs; [
        xorg.libX11 xorg.libXcomposite xorg.libXcursor xorg.libXdamage xorg.libXext xorg.libXfixes
        xorg.libXi xorg.libXrandr xorg.libXrender xorg.libXtst xorg.libxcb xorg.xcbutilkeysyms xorg.libXxf86vm
      ];
    in builtins.foldl' (a: b: "${a}:${b}/lib") "/run/opengl-driver/lib:/run/opengl-driver-32/lib" inputs;
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    layout = "us,ru";
    xkbOptions = "grp:caps_toggle, grp_led:caps, compose:ralt";
    displayManager = {
      lightdm.enable = true;
      autoLogin = {
        enable = false;
        user = "nutsalhan87";
      };
    };
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        dmenu
        i3status-rust
        i3lock
        alacritty
      ];
    };
    screenSection = ''
      Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
      Option "TearFree" "true"
    '';
  };

  fonts.fonts = with pkgs; [
    iosevka-bin noto-fonts noto-fonts-emoji noto-fonts-cjk liberation_ttf unscii
    source-code-pro source-sans-pro source-serif-pro roboto roboto-slab roboto-mono
    open-sans fira fira-code
   ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };

  users.users.nutsalhan87 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "adbusers" "libvirtd" "audio" ];
    shell = pkgs.fish;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; let
    nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec -a "$0" "$@"
    '';
  in [
    vim
    wget
    firefox
    unzip
    networkmanagerapplet feh 
    nvidia-offload
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.dconf.enable = true;
  programs.fish.enable = true;

  # List services that you want to enable:

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

