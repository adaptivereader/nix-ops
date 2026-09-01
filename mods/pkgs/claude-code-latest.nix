{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.252";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "16q44iyrm84x4plncxnqwviqi8z5g71hn5ikw1g786h5jnj525fi";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0smhmmsdmb97lkj0ggswjjnjbhzzp2anmy238fds8zkc5glk53x0";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1yr4k1b2k23zc5kh6735rrxy0vyvykd3vhh8hslia0pi4v5kikpc";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1sdx9vymbfg9s8lhgyb8lzlyh80k3289r5wpvglnkdg7mcc4d28q";
    };
  };

  platform = platformMap.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code-${platform.npmPlatform}/-/claude-code-${platform.npmPlatform}-${version}.tgz";
    inherit (platform) sha256;
  };
in
stdenv.mkDerivation {
  pname = "claude-code-latest";
  inherit version src;

  sourceRoot = "package";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 claude $out/bin/claude
    runHook postInstall
  '';

  meta = with lib; {
    description = "Claude Code CLI - AI-powered coding assistant by Anthropic";
    homepage = "https://github.com/anthropics/claude-code";
    license = licenses.unfree;
    platforms = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
    mainProgram = "claude";
  };
}
