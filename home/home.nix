{ config, pkgs, old-pkgs, vscext, ... }:

{
  nixpkgs.config.allowUnfreePredicate = (pkg: true); # workaround

  programs.home-manager.enable = true;
  home = {
    username = "nutsalhan87";
    homeDirectory = "/home/nutsalhan87";
    stateVersion = "22.05";
    file = {
      ".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ-AA";
      ".jdks/jdk8".source = pkgs.openjdk8;
      ".jdks/jdk17".source = pkgs.jdk17;
      ".config/i3/config".source = ./config/i3config;
      ".config/i3status-rust/config.toml".source = ./config/i3status.toml;
      ".config/mimeapps.list".source = ./config/mimeapps.list;
      ".config/alacritty/alacritty.yml".source = ./config/alacritty.yml;
      ".config/discord/settings.json".source = ./config/discord.json;
      ".config/flameshot/flameshot.ini".source = ./config/flameshot.ini;
    };
  };
  
  home.packages = with pkgs; [
    # creativity
    imagemagick
    krita
    kdenlive

    # gaming
    wineWowPackages.stagingFull
    winetricks
    gzdoom

    # media
    ffmpeg
    vlc
    mediainfo
    obs-studio
    microsoft-edge

    # communcation
    zoom-us 
    tdesktop
    discord
 
    # documents
    libreoffice

    # utilities
    flameshot
    pavucontrol
    qpwgraph
    qbittorrent
    xclip
    xorg.xev #чтобы узнать название клавиши
    pulseaudio
    htop
    ncdu # для того, чтобы узнать, что сколько занимает
    selectdefaultapplication
    unar
    tree
    cinnamon.nemo
    cinnamon.xviewer
    progress
    zip

    # development
    jdk17
    maven
    postgresql
    git
    (python3.withPackages (p: with p; [
      numpy
      pandas
      scipy
      matplotlib
      ipykernel ipympl
    ]))
    gcc
    gdb 
    gnumake
    jetbrains.idea-ultimate
    postman
    umlet
    rustup
  ];

  programs = {
    firefox.enable = true;
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        ms-vscode.cpptools
        twxs.cmake
        ms-vscode.cmake-tools
        ms-toolsai.jupyter ms-toolsai.jupyter-renderers
        redhat.java
        jnoortheen.nix-ide
        ms-python.python
        rust-lang.rust-analyzer
        dotjoshjohnson.xml
      ] ++ (with vscext; [
        tauri-apps.tauri-vscode
      ]);
    };
  };

  gtk = {
    enable = true;
    font = {
      name = "Roboto";
      size = 11;
    };
    theme = {
      name = "Orchis";
      package = pkgs.orchis-theme;
    };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = {
      name = "adwaita";
      package = pkgs.adwaita-qt;
    };
  };

  services.picom.enable = true;
}
