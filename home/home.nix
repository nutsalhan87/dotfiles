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

  vscode-config = import ./config/vscode.nix { pkgs = stable-pkgs; };
  xdg-config = import ./config/xdg.nix { inherit pkgs; };
  hyprland-config = import ./config/hyprland.nix { inherit pkgs nix-colorizer python-pkg flameshot-pkg; };
  darkman-config = import ./config/darkman.nix { inherit pkgs python-pkg; };

in builtins.foldl' (a: b: stable-pkgs.lib.attrsets.recursiveUpdate a b) {} [ 
  {
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
      stateVersion = "25.05";

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
        EDITOR = "nano";
        TERMINAL = "kitty";
        JAVA_TOOL_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
        PNPM_HOME = "${homeDirectory}/.pnpm";
      };

      sessionPath = [ "$PNPM_HOME" ];

      packages = with pkgs; [
        # creativity
        imagemagick
        krita

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

        # communcation
        tdesktop
        zulip
  
        # documents
        libreoffice
        djview
        # obsidian

        # utilities
        pavucontrol
        qpwgraph
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
        linuxPackages.perf
        wl-clipboard
        tldr
        v2rayn
        dnslookup

        # development
        maven
        postgresql
        git
        python-pkg
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
        cryptsetup
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
      thunderbird = {
        enable = true;
        profiles = {};
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
            useGrimAdapter = true;
          };
        };
      };
      blueman-applet.enable = true;
      network-manager-applet.enable = true;
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
  }
  vscode-config
  xdg-config
  hyprland-config 
  darkman-config
]
