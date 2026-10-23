final: prev: prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  # Toybox 0.8.15 enables readahead on macOS, which lacks posix_fadvise.
  toybox = prev.toybox.override {
    extraConfig = ''
      # CONFIG_READAHEAD is not set
    '';
  };
}
