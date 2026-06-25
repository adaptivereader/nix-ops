{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.191";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1vjnidh56gn3fywxlh1qw6f3c9rbz2z3vhp2g66z9hkwhmhdggaa";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0p53bsydhmqw1ji5qcal2m60zn5rfrf8jpbdk3z4slm66x3cjgyk";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0m5hxsf8k465v9qagi1iv3xznrwx5rl3g8zbmm4kjfhpyyf2kmn9";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1n22wi8s0k7cabjzsxjzyzj10abj65rfchcaagw6isrg6im6nwci";
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
