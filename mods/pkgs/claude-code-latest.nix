{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.128";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1xf7v0rghwym28allwsl47iybxns668s6cffwcl0vrldv99yls45";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1k0x38lggpmp1hqqb343cs1i84dqslr9krq4n1k7n6gy31xmki2w";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1skz0f1749gq5rz02n8j9gxg7xm684y0j7qxi14h1bx0jyvy7xns";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "16i1qvjvnp9jn08fpxc89qb31qmi8g693z4n14s6jxwnzkjfvmgk";
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
