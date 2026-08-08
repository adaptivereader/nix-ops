{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.225";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1g8i6kdp74nz0czzcvywkfy8s60sbcmi28sqz9b9bcvg0x1sr7v2";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1k259j61qcg0z3ygx5aw1m9pq1lqvgmidccpsdbx1zq3iyvxgsbw";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1w5y9zjflmcnci5fz9wl74ff92mkx4rjvvi5sbib774gjfjgpz6s";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "03xcrmfrhrmmb39dffnnqn8yggm7gclmxxxibsn18g0x1nsa356z";
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
