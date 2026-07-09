{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.205";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0a0bakappjp4pbphgyxi4mrn1qybzsm1blwgpcvk15b9wxfld494";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "02wpn007h84ki3c1xg75bkpq4031ksx9a7pgdkzl38vwg08f6smv";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1i0vr9x0596ig9kmvb0b314qh8lija46vssmqy1ar572rnlxznnk";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0irqnlqvgaa9hnmiabxkairinmmsmady0jhm5p7pqqv953ly5gmr";
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
