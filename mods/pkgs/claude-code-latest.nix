{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.286";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0cigx8yxnp9j5jmsggbbbym77gbs21frrgjg3kcb4qwcgv3hf0c6";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0yw9p1bskc2dvinqvcjy8s8id96yj5dlzd19l082gaadgg2rpn37";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1q43lvcxi0vdcf0i57nbg8w9x6j60jpcbc6m9nzyankcbq9dg1s8";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "15zk219grbdhw350plbnyv6mzjlc3p9k8y9wzjk5l10w6dyr91xb";
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
