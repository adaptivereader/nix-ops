{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.268";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1jgdmcxnxyjvwv9yrpy51g57b8rf2xbpzprdx4h9ml313dsr12ri";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1gyz6i366wndy3ra8k2w2gx111an30mafnrrrm8pjir0ms66z7j9";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "11al3b32ij9xgx1bx2jl0jm54bwkng2l153m0bcgqhv8gijfc8xl";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "01dm5yxypa29l9y1c3hrny8cwv004ycva5raq2qxqm02crlbawin";
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
