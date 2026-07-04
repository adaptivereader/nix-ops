{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.201";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1x0vvwqlly0w26imzrsdg0zm486v6n999272vzwyiwmsxnrf2973";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "19j1nmljd61ik90nriz63g68qq8xybd7ms4m4msslzs13zakmbr0";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1p57lxiqmpl162qlkng0sx5p7wgpjhdvig6xni6hph3rja7816c9";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0z8wx21pv19mygjcyj6vwaf346c6iljigswrad24ikdi6mn9dqgq";
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
