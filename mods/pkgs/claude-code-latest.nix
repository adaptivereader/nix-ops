{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.143";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0x9ddhmazc9p23c4srzq7vd89zw7k207pwz3rpxw1xjyd7ig4flr";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0y8r9zkj2bdgisnh3w73j9psii5vc92nl0xrf1pvg89jlwimz7pq";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1165r7xqcs4vs6l613469pkiv3xvy6rhbh0r9ma4dqvhbrv21qk3";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0r46nvfq2z6r0821gzjp0mvjvxm4v42d3gi42266kf72lwj2n3d2";
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
