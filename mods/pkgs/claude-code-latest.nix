{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.157";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "18x3ziwxbl1582f3n18f97rd5764pwnxplzxkb3618rkh4yn54c4";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1x1k6vjggwa1z1ckpsn958n7pq2nq2xaw6as6c09xak3bkayqav3";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "163prwjsjc77zphi525jbzqsqqbkf1pkqrxi2f05l33ji6vb0868";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1w4k59c7d9xgd0qx73l53b9k539gcg5zikihi98kdh1gja6g5ylk";
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
