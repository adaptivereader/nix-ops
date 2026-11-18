{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.327";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1vv69qhqdnl9qgcqgain86yxlzx70faywpjry1qpcv69m3mp68y3";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "14qb6ryjkqwnq29ac3zyy71hiaxdfpvjpwagr31jzm6drdjk9f5b";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1g1pcijfd04h2rmq18z34lzd6iyv8q06p6fbczsyzskvmlb2v7k8";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0v9bq6y7q6pk1ca89dld9jf9qkam8vpr29847fzsk7bxbags7g4l";
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
