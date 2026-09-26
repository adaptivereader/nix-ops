{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.283";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "14amykbayp27f4k36ibn4bk3p6rnb7lnyb8gw4shrgkn3489j5yf";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "09m84x0rh4bs1rckcpyanzkw73wf23mbzjxhvlz6w4a0k2hnh0wm";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1yvacwj5r9djxvwf3rlhg8gj6f4fgvm8z4i6r6910580lkyc0kni";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1xqbfz4casfd6k2dsha8rm1h1ilsnhgwvgc5v53y8w5d14mjmsp5";
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
