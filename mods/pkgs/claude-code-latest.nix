{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.139";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1687m2190pa42hd2dwhfz69agrzwb15smxlz72l4sdxmr1j4r6pd";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0v7y6aw8b1822n265dxj74mz4fy84hs97dfwgd17pwspskhqrlbi";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1r8lgdicaxvb7pr9i5ysk0si8x7wr96qhm1nvg34ppl3i3ai47k7";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0g1dd45y806mc0ad4n49mdswxp1fvv06l823ycili21zy6rlrmci";
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
