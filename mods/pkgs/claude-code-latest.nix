{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.211";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0fvf22lz5wy9mpbwzlc4vgcsv7jdl6l4mkk6wiq73q2y4a9awbfz";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0rrjxkif77p1cq2ywj6q05l05psbhd1lbbws1i58yx175x2wkj5c";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1is99nsr0wgl232asil0vs9jpqldryl9jnmh879qhyz3mwzlqksh";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1xi44s6i5z8gkrk0ac0spfmhj7j9nsqn2z168qwnwpxf1jlmbg2d";
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
