{ config, pkgs, stable-pkgs, nix-colorizer, fenix, ... }: let
  
  rust-toolchain = with fenix; combine (with complete; [
    rustc
    rust-src
    cargo
    clippy
    rustfmt
    rust-analyzer
  ]);

in {
  imports = [
    ./config/darkman.nix
    ./config/xdg.nix
    ./config/vscode.nix
    ./config/hyprland
  ];

  home = rec {
    username = "nutsalhan87";
    homeDirectory = "/home/nutsalhan87";
    stateVersion = "22.05";

    file = {
      ".jdks/jdk8".source = pkgs.openjdk8;
      ".jdks/jdk17".source = pkgs.jdk17;
      ".jdks/jdk21".source = pkgs.jdk21;
      ".pnpm/.keep".text = "";
    };

    shellAliases = {
      bsave = "sudo cpupower frequency-set -g powersave";
      bstd = "sudo cpupower frequency-set -g schedutil";
      xo = "xdg-open";
    };

    sessionVariables = {
      RUST_SRC_PATH = "${rust-toolchain}/lib/rustlib/src/rust/library";
      MPLBACKEND = "webagg";
      MOZ_USE_XINPUT2 = "1";
      EDITOR = "vim";
      TERMINAL = "kitty";
      JAVA_TOOL_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
      PNPM_HOME = "${homeDirectory}/.pnpm";
    };

    sessionPath = [ "$PNPM_HOME" ];

    packages = with pkgs; [
      # creativity
      imagemagick
      krita
      inkscape

      # gaming
      wineWow64Packages.waylandFull
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
      nemo
      xviewer

      # communcation
      zoom-us 
      telegram-desktop

      # documents
      libreoffice
      djview

      # utilities
      pavucontrol
      qpwgraph
      qbittorrent
      wev # чтобы узнать название клавиши
      pulseaudio
      htop
      ncdu
      selectdefaultapplication
      unar
      tree
      nemo
      xviewer
      progress
      zip
      perf
      amdgpu_top
      wl-clipboard
      tldr
      xray

      # development
      maven
      postgresql
      git
      (python3.withPackages (p: with p; [
        numpy
        pandas
        scipy
        matplotlib
        ipykernel ipympl
        requests
        black
      ]))
      gcc
      gdb
      gnumake
      umlet
      rust-toolchain
      nodejs
      nodePackages.pnpm
      php
      shellcheck-minimal
      clang-tools
      poetry
      openssl
      nixfmt
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
    chromium.enable = true;
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        setEnv = {
          TERM = "xterm-256color";
        };
      };
      includes = [ "config.d/*" ];
    };
    kitty = {
      enable = true;
      themeFile = "Alabaster_Dark";
    };
    java = {
      enable = true;
      package = pkgs.jdk21;
    };
    vim = {
      enable = true;
      settings = {
        number = true;
      };
    };
    man.generateCaches = false;
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
          useGrimAdapter = true;
        };
      };
    };
    blueman-applet.enable = true;
    network-manager-applet.enable = true;
  };

  systemd.user.services = {
    xray = {
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Unit = {
        Description = "A unified platform for anti-censorship";
      };
      Service = {
        ExecStart = "${pkgs.xray}/bin/xray run";
        Environment = [
          "XRAY_LOCATION_ASSET=%D/xray"
          "XRAY_LOCATION_CONFIG=%E/xray"
        ];
      };
    };
  };

  gtk = let 
    gtk-config = {};
  in {
    enable = true;
    font = {
      name = "Roboto";
      size = 11;
    };
    theme = {
      name = "Fluent-Dark";
      package = pkgs.fluent-gtk-theme.override { tweaks = [ "blur" ]; };
    };
    iconTheme = {
      name = "Fluent-dark";
      package = pkgs.fluent-icon-theme;
    };
    gtk3.extraConfig = {} // gtk-config;
    gtk4.extraConfig = {} // gtk-config;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  my = {
    dpms = true;
    keyboard_led = true;
    screen_brightness = true;
    mic = true;
    card-path = "/dev/dri/by-path/pci-0000:05:00.0-card";
    is-nvidia = false;
    battery = true;
  };
}
