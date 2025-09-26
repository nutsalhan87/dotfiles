{ pkgs }:

{
  xdg = {
    enable = true;
    autostart = {
      enable = true;
      readOnly = true;
      entries = [
        "${pkgs.v2rayn}/share/applications/v2rayn.desktop"
      ];
    };
    desktopEntries = {
      poweroff = {
        name = "Power Off";
        exec = "poweroff";
      };
      reboot = {
        name = "Reboot";
        exec = "reboot";
      };
    };
    configFile = {
      kitty-dark-theme = {
        target = "kitty/dark-theme.auto.conf";
        source = pkgs.kitty-themes + /share/kitty-themes/themes/Alabaster_Dark.conf;
      };
      kitty-light-theme = {
        target = "kitty/light-theme.auto.conf";
        source = pkgs.kitty-themes + /share/kitty-themes/themes/Alabaster.conf;
      };
    };
    dataFile = {
      oranienbaum = {
        target = "fonts/Oranienbaum-Regular.ttf";
        source = ../assets/Oranienbaum-Regular.ttf;
      };
    };
    portal = {
      enable = pkgs.lib.mkForce true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
        darkman
      ];
    };
    mimeApps = {
      enable = true;
      associations.added = {
        "x-scheme-handler/tg" = [ 
          "userapp-Telegram Desktop-AQATR1.desktop" 
          "userapp-Telegram Desktop-EWUET1.desktop" 
          "userapp-Telegram Desktop-XT3IV1.desktop" 
          "userapp-Telegram Desktop-3MDWW1.desktop" 
          "userapp-Telegram Desktop-DQS9Z1.desktop" 
          "userapp-Telegram Desktop-TGDS01.desktop"
        ];
      };
      defaultApplications = {
        "x-scheme-handler/tg" = "userapp-Telegram Desktop-TGDS01.desktop";
        "image/heif" = "feh.desktop";
        "application/x-krita" = "org.kde.krita.desktop";
        "application/pdf" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/vnd.palm" = "writer.desktop";
        "application/vnd.sun.xml.writer.template" = "writer.desktop";
        "application/x-mswrite" = "writer.desktop";
        "application/x-fictionbook+xml" = "writer.desktop";
        "application/vnd.oasis.opendocument.text" = "writer.desktop";
        "application/vnd.lotus-wordpro" = "writer.desktop";
        "application/x-t602" = "writer.desktop";
        "application/x-hwp" = "writer.desktop";
        "application/vnd.wordperfect" = "writer.desktop";
        "application/x-abiword" = "writer.desktop";
        "application/vnd.oasis.opendocument.text-web" = "writer.desktop";
        "application/vnd.sun.xml.writer.global" = "writer.desktop";
        "application/msword" = "writer.desktop";
        "application/vnd.oasis.opendocument.text-flat-xml" = "writer.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = "writer.desktop";
        "application/vnd.sun.xml.writer" = "writer.desktop";
        "application/vnd.ms-works" = "writer.desktop";
        "application/vnd.stardivision.writer" = "writer.desktop";
        "application/vnd.apple.pages" = "writer.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
        "application/vnd.oasis.opendocument.text-template" = "writer.desktop";
        "application/prs.plucker" = "writer.desktop";
        "application/vnd.oasis.opendocument.text-master" = "writer.desktop";
        "image/x-xbitmap" = "xviewer.desktop";
        "image/x-tga" = "xviewer.desktop";
        "image/tiff" = "xviewer.desktop";
        "image/bmp" = "xviewer.desktop";
        "image/x-portable-anymap" = "xviewer.desktop";
        "image/vnd.microsoft.icon" = "xviewer.desktop";
        "image/vnd.zbrush.pcx" = "xviewer.desktop";
        "image/svg+xml" = "xviewer.desktop";
        "image/webp" = "xviewer.desktop";
        "image/vnd.wap.wbmp" = "xviewer.desktop";
        "image/x-xpixmap" = "xviewer.desktop";
        "image/png" = "xviewer.desktop";
        "image/gif" = "xviewer.desktop";
        "image/jpeg" = "xviewer.desktop";
        "image/svg+xml-compressed" = "xviewer.desktop";
        "inode/directory" = "nemo.desktop";
        "x-scheme-handler/postman" = "Postman.desktop";
      };
    };
  };
}
