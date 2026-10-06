{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.290";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1xm52nsh5wzbfxy2wmzvmddizwk8vgl07dc2ysws7c19cr8yr8yx";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0jrd2mxrah7c1iv135aramsmz2151jx78brszc2qnl2j8cdg29wy";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "10kpmna1h4ypykl4ziyh4l2cghdiwr1s8fcx85w3r0vdg5qjkdf1";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1z2d588z57nn268gbbkn2rz2qpyrl2wj8ysfdzybyi18b6080nj3";
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
