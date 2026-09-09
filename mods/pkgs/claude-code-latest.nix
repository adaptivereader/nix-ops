{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.266";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1bkcxs4y8kqbms48yaha03abgfqcsvj4mnpycgrqa67r58g565if";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "17fnbnd8fi5x2xfppabivh1npr81shmggrwj5dpxgpkbfrjw3svc";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1rfc196pic9s8rlnn9snyrbsbzka5bwqklq0hjm2ayw5na021wa9";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "02fsbnsykynv115l2mxjr6f4803sf55k94d62jzg057vi9qb3g6r";
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
