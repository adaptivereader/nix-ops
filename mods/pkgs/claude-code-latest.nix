{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.149";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0s9qmxzm67f499x1szy1166pqibnc7afkqqs1lvc5s2vgvw4qkl1";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "05alnvdz2hxjrsw2naqvz8j9s8gspqynwwrb1dvdlvag5vvd2lhj";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1lqg21gjm3f0zl33yhqsmljb0jnq3dlh8aqxfsjgcxvaph53xjd5";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1ghsvvvdjh1b4g1d1fa7alwj9rzg23v04f9q67wx1lg9crndiws0";
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
