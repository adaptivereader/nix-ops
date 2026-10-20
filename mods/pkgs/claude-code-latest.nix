{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.304";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1yb3b69fadjm0ygw5w9d2rapakas1gkj8awzz02d8mw0vp4662xf";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1wmq3jhriwf7aybmif395ljgh91byg07rkgpl68rigv7jh2ydsbb";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "05fdi9mg054j61s5f56615g828nasfvw5nbvvw9y7hii8vjlxnhy";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "07l1ln7vb1m64b8yq5mfwy1ynyknp16k0ck3lfa37xia4d4cp0l9";
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
