{ config, pkgs, old-pkgs, ... }:

{
  nixpkgs.config.allowUnfreePredicate = (pkg: true); # workaround

  home = let rust-toolchain = with pkgs.fenix; combine (with complete; [
    rustc
    rust-src
    cargo
    clippy
    rustfmt
    rust-analyzer
  ]);
  gsettings-desktop-schemas = pkgs.gsettings-desktop-schemas;
  gtk3 = pkgs.gtk3; in

  {
    username = "nutsalhan87";
    homeDirectory = "/home/nutsalhan87";
    stateVersion = "22.05";

    file = {
      ".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ-AA";
      ".jdks/jdk8".source = pkgs.openjdk8;
      ".jdks/jdk17".source = pkgs.jdk17;
      ".config/i3/config".source = ./config/i3config;
      ".config/i3status-rust/config.toml".source = ./config/i3status.toml;
      ".config/discord/settings.json".source = ./config/discord.json;
      ".config/flameshot/flameshot.ini".source = ./config/flameshot.ini;
    };

    sessionVariables = {
      RUST_SRC_PATH = "${rust-toolchain}/lib/rustlib/src/rust/library";
      MPLBACKEND = "webagg";
      MOZ_USE_XINPUT2 = "1";
      EDITOR = "nano";
      TERMINAL = "alacritty";
      JAVA_TOOL_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
      XDG_DATA_DIRS = "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:\${XDG_DATA_DIRS}";
    };

    packages = with pkgs; [
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
      rust-toolchain
      nodejs
      php
    ];
  };
  
  programs = {
    home-manager.enable = true;
    firefox.enable = true;
    fish.enable = true;
    alacritty = {
      enable = true;
      settings = {
        font = {
          family = "Iosevka Term";
          size = 7;
        };
        window.opacity = 1;
      };
    };
    vscode = {
      enable = true;
      package = pkgs.vscodium.fhs;
    };
  };

  gtk = {
    enable = true;
    font = {
      name = "Roboto";
      size = 11;
    };
    theme = {
      name = "Fluent";
      package = pkgs.fluent-gtk-theme;
    };
    iconTheme = {
      name = "Fluent";
      package = pkgs.fluent-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita";
      package = pkgs.adwaita-qt;
    };
  };

  services.picom.enable = true;

  xdg = import ./config/xdg.nix;
}
