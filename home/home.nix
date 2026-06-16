{ config, pkgs, lib, unstable-pkgs, nix-colorizer, fenix, ... }: let
  
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

  config = {
    home = rec {
      username = "nutsalhan87";
      homeDirectory = "/home/nutsalhan87";
      stateVersion = "25.05";

      preferXdgDirectories = true;

      file = {
        ".jdks/jdk8".source = pkgs.openjdk8;
        ".jdks/jdk17".source = pkgs.jdk17;
        ".jdks/jdk21".source = pkgs.jdk21;
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
        PNPM_HOME = "${config.xdg.dataHome}/pnpm";
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
        telegram-desktop
        zulip

        # documents
        libreoffice
        djview

        # utilities
        pavucontrol
        qpwgraph
        wev # чтобы узнать название клавиши
        pulseaudio
        htop
        ncdu
        selectdefaultapplication
        unar
        tree
        progress
        zip
        perf
        wl-clipboard
        tldr
        dnslookup
        sshfs
        cryptsetup
        android-tools
        jq

        # development
        maven
        postgresql postgresql.pg_config libpq
        git
        (python3.withPackages (p: with p; [
          numpy pandas scipy matplotlib
          ipykernel ipympl
          requests psycopg
          black
        ]))
        gcc gdb gnumake
        umlet
        rust-toolchain
        nodejs pnpm
        php
        shellcheck-minimal
        clang-tools
        poetry
        openssl
        ansible
        nixfmt
        redis
      ] ++ (with unstable-pkgs; [
        xray
        opencode
      ]);

      pointerCursor = {
        name = "graphite-light-nord";
        package = pkgs.graphite-cursors;
      };

      activation.darkman = lib.hm.dag.entryAfter [ "reloadSystemd" "dconfSettings" ] ''
        if [ -z "$${DRY_RUN:-}" ]; then
          echo "Darkman set $(${pkgs.darkman}/bin/darkman get) (dry run)"
          exit 0
        fi
        for darkman_script in $XDG_DATA_HOME/darkman/*; do
          run --quiet $darkman_script $(${pkgs.darkman}/bin/darkman get)
        done
      '';
    };
    
    programs = {
      home-manager.enable = true;
      firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
      };
      fish.enable = true;
      chromium.enable = true;
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings."*" = {
          ForwardAgent = false;
          AddKeysToAgent = "no";
          Compression = false;
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          SetEnv = {
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
        package = pkgs.jdk25;
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
      network-manager-applet.enable = true;
      blueman-applet.enable = false;
    };

    gtk = {
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
      gtk4.theme = config.gtk.theme;
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "breeze";
    };

    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };

    my = {
      dpms = false;
      keyboard_led = false;
      screen_brightness = false;
      mic = false;
      card-path = "/dev/dri/by-path/pci-0000:2b:00.0-card";
      is-nvidia = true;
      battery = false;
      cpu = {
        cores = 16;
        hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
      };
    };
  };
}
