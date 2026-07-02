{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.198";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0x623kqa30f6lw57pdrh5hsgy3jcv6jg5fwgf8hrsgz1603kr61b";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1l8a8859rfyfl752a7vqxls1asbr2jbmfqkpga8pazpyawbbpsmc";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0izh9p866q67k84yf8kb5g1ahw95iag02akbv4aylpjz8can4hr6";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0qnv55wkq6gb8mbza7d8m1mbyhvyxsb6j5qq274jfrl46xxmw5c3";
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
