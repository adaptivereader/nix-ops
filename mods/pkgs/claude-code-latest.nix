{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.284";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1926dzbnsp9bzvcrl2lvi26czbf3lml2kyvr0x6p8kiikria1350";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "18mzycbdwzfh14312cap30di5qpiq9a9yqq32bsm34m58bjgbjm4";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "09qhgwy5xvwhrngcqvffgy2qbjimih6m47il2yf048mamz1r09k4";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1azpyc4zcnlbp6yrkvkg3hjmxnqcpq2v246aw0qnizsl2hhvj604";
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
