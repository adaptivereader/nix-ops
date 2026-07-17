{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.212";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1k40h332bjqg3x4y5hfmv8nkfxj4x9x2m4g4d4srpdsb6x8c5ygl";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "13l4wjajnmq2bffif293hb10765x81knqx5nl17al96gy1sdm7r5";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1z0wl14j24n07sh8hc916bzz8mnww4jl58zzvifai5fcibq4xi78";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1y6v23ls100fbbx7bskwv5jxw11bz0jhwic77hchmqizxnmsv8aa";
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
