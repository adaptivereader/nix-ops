{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.214";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1fx6mgx7risz5dm2h49g7mwcx8f1i2bpfkgrl8hkzxq0rz832cq6";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "02wibl24nm26qmxqnka8hi6y8wq10s5zawdb2fyixygfilb61r1a";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1afk3ij4ik4d569ki6rpn9chk4sxg2jqri6cw3nxv47bpcn48bza";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "02rgrkk9bi1w2x324vzm1l5pypcv6n52w5c2hjcs7zyl0nq5bxb4";
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
