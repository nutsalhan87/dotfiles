{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfreePredicate = (pkg: true); # workaround

  programs.home-manager.enable = true;
  home.username = "nutsalhan87";
  home.homeDirectory = "/home/nutsalhan87";
  home.stateVersion = "22.05";
  
  home.packages = with pkgs; [
    # creativity
    discord
    inkscape
    imagemagick
    krita
    mediainfo

    # gaming
    wineWowPackages.stagingFull
    winetricks
    gzdoom

    #media
    ffmpeg
    vlc

    # communcation
    zoom-us 
    tdesktop
    
    # documents
    libreoffice

    # utilities
    any-nix-shell
    maim
    obs-studio
    pavucontrol
    qpwgraph
    qbittorrent
    xclip
    xorg.xev #чтобы узнать название клавиши
    jdk17
    maven
    postgresql
    git
    pulseaudio
    (python3.withPackages (p: with p; [
      numpy
      pandas
      scipy
    ]))
    nasm #ass
    gcc #ass
    gdb #ass
    gnumake #ass
    binutils #ass
    htop
#    i3lock
    jetbrains.idea-ultimate
    ncdu # для того, чтобы узнать, что сколько занимает
    php
    selectdefaultapplication
    unar
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.cpptools
      dotjoshjohnson.xml
      ms-python.python
      redhat.java
    ];
  };

  home.file = {
    ".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ-AA";
    ".jdks/jdk8".source = pkgs.openjdk8;
    ".jdks/jdk17".source = pkgs.jdk17;
    ".config/i3/config".source = ./i3config;
    ".config/i3status-rust/config.toml".source = ./i3status.toml;
  };

  home.sessionVariables = {
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

  gtk.enable = true;

  gtk.font = {
    name = "Roboto";
    size = 11;
  };

  gtk.theme = {
    name = "Arc";
    package = pkgs.arc-theme;
  };

  gtk.iconTheme = {
    name = "Arc";
    package = pkgs.arc-icon-theme;
  };

  qt.enable = false;
  qt.platformTheme = "gnome";
  qt.style.package = pkgs.adwaita-qt;
  qt.style.name = "adwaita";

  programs.firefox.enable = true;

  programs.fish = {
    enable = true;
  };

  services.picom.enable = true;
}
