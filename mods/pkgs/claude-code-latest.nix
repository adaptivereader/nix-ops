{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.272";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "01i0lm0z3dh6swcb94hn3zh910gv5brd1nfi9iqc42rw713hvmw4";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1viqd0fghvj1337wv2q1rzqsg4wq5085gnvmp8mdjs7x1xhvmzlz";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1g58vn2ghgfj80mck86rx3n6lixgpf3rdhwf9wgd8w7m9pxpivcc";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0gwcc0is3lblhmwzffwn10xapdyzln5qdahg8z0wkwzmrccnyav4";
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
