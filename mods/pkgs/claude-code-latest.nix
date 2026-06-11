{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.172";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0vfgr787c2j1lgycidjg7fk9df5jm85vs9v9ji4h2yq914wm0sxh";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1bq2y45m1sa4ws6y35gipxnjn7rss5gyvlik641bw6f6fvfkc0v7";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1i2wn7nsl0bnww5ifk3h71ifqw5avyhk6kjcchrr1s877vgr5raa";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "19gxa4r6rp1hsz6rqcah13v2fixljphk6kncp33pqib0763smxdm";
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
