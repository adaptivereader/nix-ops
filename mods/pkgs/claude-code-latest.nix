{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.199";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "07sngb8iwiqpggr6izzlf2gg9lvq60l7b56rxpd7jflby7hw6vmd";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "17553ldzzfb18jg84322xm7msnbyvp5b8slq8w3p63lmf760hplq";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0dzc2nm2p2pppl069y4gq3dyx765hc7n3d9li172ddp02xj0gqkc";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0qfcwy99xfmzbmsi6g0vjpa877mnwjw19zlc73wjcxdida9yhd74";
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
