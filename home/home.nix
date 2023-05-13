{ config, pkgs, old-pkgs, ... }:

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

  programs = {
    firefox.enable = true;
    vscode = {
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
    style.package = pkgs.adwaita-qt;
    style.name = "adwaita";
  };

  
  services.picom.enable = true;
}
