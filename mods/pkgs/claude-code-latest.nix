{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.170";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0lxaavp0i6glbf6ghyn3xszx1qs2kncm9s3g52apx0h35zfrkmlm";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1c4b7q6b41xjspyayifjwlq8ak25hxdr9gjcmbyakhrx2xak5rpk";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1zskrnfdgnivkl88fxgxvfasfslcg54439mimvyl4drbc73x82as";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0kn17646yqw5xk6zkyyad18yda3y2pv392arzyl3w0r1j5s597cy";
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
