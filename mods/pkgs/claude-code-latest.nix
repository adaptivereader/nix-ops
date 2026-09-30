{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.285";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0ni3si2hi2ngpd7nsals1iklwy5fxivq30fi000hx6795fm68507";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1n9anvw59imqg1ip7k20ysn5mvvh4vdh7k14acv37r56jp8m1vb1";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1zhz6k1wi1svx3b5s53s8f0aqiz3k1k14nbypxp26hjz5nzimsiz";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1gscrvd7cxy542bnysd1i6q0i2brvd8mld1as6yn1j5kkm9xr87q";
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
