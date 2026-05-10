{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.138";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1m193snz6miq0iq82lkgmk018cja20v4zsr0rm89i0dp9yws3q13";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0d4rbjvvg9gbc9kyy597w2lmh49xpg2wwpc4sriqn1hszpi4czvk";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "01rij52ll7ii73kdb8jdywgjgcqzlgrj1kw3b8irid4mi6yb7373";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0hyf3k3rgwnzmlzz5kj42zg1lznb8cdy13h0f7jklaanrsd1zi55";
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
