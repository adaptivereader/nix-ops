{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.222";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "02fxl8lvp89l5dhigj2gmdxl2grwayz38q7ncfp9i6jwwmm0a02w";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0826ixfvlb96hrpsz1vz2ipa5g2k0s29y8gq3xlllldz8380mp6f";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1zy14nil300kbphwlya6pdhkqd3f36rvwz3rhiyb9aivdxdi5036";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1px1ww628vw4z9a32930agjd3v00cryf4vl52n5d0bb59lvcicqv";
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
