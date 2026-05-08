{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.133";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "168q55lgzsiq5f7d4w2q4zmxxbgq4hhf0vjg2l6shc5xqwsp0fpl";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1k7h6gc0qddip4m67i65cjgbsyx238n5aa3m9svglprx91kqsrr6";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1yv02p2cjilsvzjz6ljhjc1lail792ksncvjf7k22xqhky6lh2nz";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0azm7f0c2z73dgx0m26n545qg6h8n0ahd5d4jd1mplgxsvp0g2p8";
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
