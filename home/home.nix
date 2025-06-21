{ config, pkgs, stable-pkgs, nix-colorizer, fenix, ... }: let
  
  python-pkg = (pkgs.python3.withPackages (p: with p; [
    numpy
    pandas
    scipy
    matplotlib
    ipykernel ipympl
    requests
  ]));
  flameshot-pkg = pkgs.flameshot.override { enableWlrSupport = true; };

  ui-scale = 1;
  
  xdg-config = import ./config/xdg.nix { inherit pkgs; };
  i3-config = import ./config/i3.nix { inherit pkgs nix-colorizer python-pkg flameshot-pkg ui-scale; };
  hyprland-config = import ./config/hyprland.nix { inherit pkgs nix-colorizer python-pkg flameshot-pkg ui-scale; };

in builtins.foldl' (a: b: stable-pkgs.lib.attrsets.recursiveUpdate a b) {} [ 
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
        ".jdks/jdk8".source = pkgs.openjdk8;
        ".jdks/jdk17".source = pkgs.jdk17;
        ".jdks/jdk21".source = pkgs.jdk21;
        ".local/share/fonts/Oranienbaum-Regular.ttf".source = ./assets/Oranienbaum-Regular.ttf;
        ".config/discord/settings.json".source = ./config/discord.json;
        ".pnpm/.keep".text = "";
      };

      shellAliases = {
        alacritty-copy = "alacritty --working-directory . & disown";
        bsave = "sudo cpupower frequency-set -g powersave";
        bstd = "sudo cpupower frequency-set -g schedutil";
      };

      sessionVariables = {
        RUST_SRC_PATH = "${rust-toolchain}/lib/rustlib/src/rust/library";
        MPLBACKEND = "webagg";
        MOZ_USE_XINPUT2 = "1";
        EDITOR = "nano";
        TERMINAL = "alacritty";
        JAVA_TOOL_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
        PNPM_HOME = "${homeDirectory}/.pnpm";
        AQ_DRM_DEVICES = "/dev/dri/card2:/dev/dri/card1"; # amd, а иначе nvidia
      };

      sessionPath = [ "$PNPM_HOME" ];

      packages = with pkgs; [
        # creativity
        imagemagick
        krita
        kdePackages.kdenlive
        gimp

        # gaming
        wineWowPackages.stagingFull
        winetricks
        gzdoom
        steam-run
        xonotic

        # media
        feh
        ffmpeg
        vlc
        mediainfo
        obs-studio
        (callPackage ./packages/yandex-browser.nix {})

        # communcation
        zoom-us 
        tdesktop
        webcord
  
        # documents
        libreoffice
        djview

        # utilities
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
        hiddify-app

        # development
        maven
        postgresql
        git
        python-pkg
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
        poetry
      ];

      pointerCursor = {
        name = "graphite-light-nord";
        package = pkgs.graphite-cursors;
      };
    };
    
    programs = {
      home-manager.enable = true;
      firefox.enable = true;
      fish.enable = true;
      alacritty.enable = true;
      vscode = import ./config/vscode.nix pkgs;
      java = {
        enable = true;
        package = pkgs.jdk21;
      };
    };

    services = {
      flameshot = {
        enable = true;
        package = flameshot-pkg;
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
      blueman-applet.enable = true;
      network-manager-applet.enable = true;
    };

    gtk = let 
      gtk-config = {
        gtk-application-prefer-dark-theme = true;
      };
    in {
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
      gtk3.extraConfig = {} // gtk-config;
      gtk4.extraConfig = {} // gtk-config;
    };

    qt = {
      enable = true;
      style = {
        name = "adwaita";
        package = pkgs.adwaita-qt;
      };
    };
  }
  xdg-config
  hyprland-config 
  i3-config
]