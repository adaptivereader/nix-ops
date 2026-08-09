{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.226";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "17dz5ac807zyga0kcl402hw6461gan2nkdarxd0bb2rx2dya1jpk";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "11hy51r2hkgkqn8jpmmmkhcy1zincbpl3ldryzsap4nn01dp68zp";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0zrxk0s3vfhw0w3q4pm83s780drmxhkbr5llrgbwhcm4hrgfkknk";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0mpgnqxciqq97n67akj6m8h8zcwjxvzsxa6xr0cd2w7zv882dfzv";
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
