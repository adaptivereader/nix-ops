{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.307";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "04zibkmdj0s8b5ia645xmdn7d1fg6i2i4c6g60a1smscx46rzmg6";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1cbpvz8vbs05qha477kjqlw0g6q36d87vp35izn7a07l8yayk5d6";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0qbd7zxymqgsaraxghrmp1sywdq0kyxhgn8vpmvv2bj8mqqb8qqp";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0x57l0w0cw7valqqcjmnzgyhcsp616zq9nl8kkbahkw1r02sbz94";
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
