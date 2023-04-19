{ config, pkgs, old-pkgs, ... }:

{
  nixpkgs.config.allowUnfreePredicate = (pkg: true); # workaround

  programs.home-manager.enable = true;
  home.username = "nutsalhan87";
  home.homeDirectory = "/home/nutsalhan87";
  home.stateVersion = "22.05";
  
  home.packages = with pkgs; [
    # creativity
    imagemagick
    krita

    # gaming
    wineWowPackages.stagingFull
    winetricks
    gzdoom

    # media
    ffmpeg
    vlc
    mediainfo

    # communcation
    zoom-us 
    tdesktop
    discord
 
    # documents
    libreoffice

    # utilities
    any-nix-shell
    flameshot
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
      matplotlib
      scikit-learn
      pillow
      seaborn
      ipykernel
    ]))
    gcc
    gdb 
    gnumake
    htop
    jetbrains.idea-ultimate
    ncdu # для того, чтобы узнать, что сколько занимает
    selectdefaultapplication
    unar
    tree
    cinnamon.nemo
    cinnamon.xviewer
    progress
    zip
    postman
    umlet
    microsoft-edge
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.cpptools
      dotjoshjohnson.xml
      ms-python.python
      redhat.java
      ms-toolsai.jupyter
    ];
  };

  home.file = {
    ".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ-AA";
    ".jdks/jdk8".source = pkgs.openjdk8;
    ".jdks/jdk17".source = pkgs.jdk17;
    ".config/i3/config".source = ./i3config;
    ".config/i3status-rust/config.toml".source = ./i3status.toml;
    ".config/mimeapps.list".source = ./mimeapps.list;
    ".config/alacritty/alacritty.yml".source = ./alacritty.yml;
    ".config/discord/settings.json".source = ./discord.json;
    ".config/flameshot/flameshot.ini".source = ./flameshot.ini;
  };

  gtk.enable = true;

  gtk.font = {
    name = "Roboto";
    size = 11;
  };

  gtk.theme = {
    name = "Orchis";
    package = pkgs.orchis-theme;
  };

  gtk.iconTheme = {
    name = "Arc";
    package = pkgs.arc-icon-theme;
  };

  qt.enable = true;
  qt.platformTheme = "gnome";
  qt.style.package = pkgs.adwaita-qt;
  qt.style.name = "adwaita";

  programs.firefox.enable = true;
  
  services.picom.enable = true;
}
