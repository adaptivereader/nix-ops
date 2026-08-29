{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.251";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1zfrykn6kik5dcgm465f22jjb8npjmrlmzmpydw0p8lyckxcygnb";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1yxfy9jdiyizxvssh34i10s9799qnb16bj051qjqmi0jq5ki5lgy";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0i0axpakiv6gy0fnsx5d16q8v913mr1icy58v794rmncp89nsbby";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0vc4hda1k6zvmxgbl97pp0wd13w0fribhnpjnszsi2gj7cl0yxjh";
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
