{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.329";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0ffzar3ya004kc3vsqikh9rpjfk0nhhy68c9f236ciwf2gbm6nvh";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0cwbq8lshnyd378dka3aggad2vyfcm4dif5nzh2zl1g8xw7a6dpa";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1fv0437h7kh87lrzh97jsjr382nw6xdp7xf18hpjv6x18626qkd7";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "13nwpjargl58v1iga7d700037h1a2yl7bhl2vkc3125wrqrqqkql";
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
