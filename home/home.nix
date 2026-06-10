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
      stateVersion = "22.05";

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
        progress
        zip
        perf
        amdgpu_top
        wl-clipboard
        tldr
        dnslookup
        sshfs
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
        shellcheck-minimal
        clang-tools
        openssl
        nixfmt
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
      dpms = true;
      keyboard_led = true;
      screen_brightness = true;
      mic = true;
      card-path = "/dev/dri/by-path/pci-0000:05:00.0-card";
      is-nvidia = false;
      battery = true;
    };
  };
}
