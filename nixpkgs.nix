{
  config.allowUnfree = true;
  overlays = [
    (final: prev: {
      lib = prev.lib.extend (lfinal: lprev: {
        mkAnything = default: lfinal.mkOption {
          type = lfinal.types.anything;
          inherit default;
        };
      });
    })
  ];
}