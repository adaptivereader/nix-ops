{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.287";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0y4jdnp5d1q86z6r8mhmnnwhys3g1ddly4x4kjkjdkr25vh5xx41";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "00zyj1nhhf82qzm7z99ajlnxsmbq945dxpwy2mrg19k8wq6im2gy";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "04b1l20h5zcf298p2h1knxz7c5y65dp27zb5cq7g5b5si7l9101l";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1g7i2ql963zzq6zy85xk9rjvpzx9a0358jv823gbk0hy7vcidbik";
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
