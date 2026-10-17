{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.302";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0m35p2rn1in4n74xvq5kxx1ajiqdbhx3kcxzcl6lqbnbhfk6y8gv";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0jzvmgml4ira5r4q9667bwy7jqjwa85rrhla27n8fvjv5xh5jyq7";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1qi5izf6im8kpb1x6xlggx4jicimvydrham0w35qjl0p0xr83i9v";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0csyv9d5yrsb1jkkd82476cnl3180r4wcky19sibnyfnn8by2fwa";
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
