{ config, pkgs, old-pkgs, nix-colorizer, fenix, ... }:

let 
  i3-config = import ./config/i3.nix { inherit pkgs nix-colorizer; }; 
in
{
  nixpkgs.config.allowUnfreePredicate = (pkg: true); # workaround

  home = let 
    rust-toolchain = with fenix; combine (with complete; [
      rustc
      rust-src
      cargo
      clippy
      rustfmt
      rust-analyzer
    ]); in
  rec {
    username = "nutsalhan87";
    homeDirectory = "/home/nutsalhan87";
    stateVersion = "22.05";

    file = {
      ".icons/default".source = "${pkgs.graphite-cursors}/share/icons/graphite-light-nord";
      ".jdks/jdk8".source = pkgs.openjdk8;
      ".jdks/jdk17".source = pkgs.jdk17;
      ".jdks/jdk21".source = pkgs.jdk21;
      ".config/discord/settings.json".source = ./config/discord.json;
      ".pnpm/.keep".text = "";
    };

    shellAliases.alacritty-copy = "alacritty --working-directory . & disown";

    sessionVariables = {
      RUST_SRC_PATH = "${rust-toolchain}/lib/rustlib/src/rust/library";
      MPLBACKEND = "webagg";
      MOZ_USE_XINPUT2 = "1";
      EDITOR = "nano";
      TERMINAL = "alacritty";
      JAVA_TOOL_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
      PNPM_HOME = "${homeDirectory}/.pnpm";
    };

    sessionPath = [ "$PNPM_HOME" ];

    packages = with pkgs; [
      # creativity
      imagemagick
      krita
      kdenlive

      # gaming
      wineWowPackages.stagingFull
      winetricks
      gzdoom
      steam-run

      # media
      ffmpeg
      vlc
      mediainfo
      obs-studio
      (callPackage ./packages/yandex-browser.nix {})

      # communcation
      zoom-us 
      tdesktop
      discord
 
      # documents
      libreoffice
      djview

      # utilities
      flameshot
      pavucontrol
      qpwgraph
      qbittorrent
      xclip
      xorg.xev # чтобы узнать название клавиши
      pulseaudio
      htop
      ncdu # для того, чтобы узнать, что сколько занимает
      selectdefaultapplication
      unar
      tree
      nemo
      xviewer
      progress
      zip
      linuxKernel.packages.linux_6_6.perf

      # development
      jdk21
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
      jetbrains.idea-community
      jetbrains.pycharm-community
      umlet
      rust-toolchain
      nodejs
      nodePackages.pnpm
      php
      insomnia
      shellcheck-minimal # для bash-ide расширения для vscode'а
      clang-tools
      zig
      zls # zig language server для vscode'а
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
          size = 7;
        };
      };
    };
    vscode = import ./config/vscode.nix pkgs;
    i3status-rust = i3-config.i3status-rust;
  };

  services = {
    flameshot = {
      enable = true;
      settings = {
        General = {
          contrastOpacity = 188;
          disabledTrayIcon = true;
          drawThickness = 8;
          showDesktopNotification = false;
          showHelp = false;
          showSidePanelButton = true;
        };
      };
    };
    picom.enable = true; # нужен ли?
    blueman-applet.enable = true;
    network-manager-applet.enable = true;
  };

  xsession.windowManager.i3 = i3-config.i3;

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
    style = {
      name = "adwaita";
      package = pkgs.adwaita-qt;
    };
  };

  xdg = import ./config/xdg.nix;
}
