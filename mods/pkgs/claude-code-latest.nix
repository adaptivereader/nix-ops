{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.142";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0xgdhyvh5l00gixqxc391c6m3dnb5zyhflk843icdjzpam39pidw";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "198nsdnifjxmqlv65m0zyfsy65c1m26ms87jisl8laz3x13w960s";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "17jrjmrssnw2slbljh499j8g64y76sdmcp4bk9bi9iabgqvzc2ad";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0sz07xqhfwjd0bq6nvmxvbghqwi9ymfgjjwz39x7dgibnsfi7z36";
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
