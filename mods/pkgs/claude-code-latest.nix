{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.243";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1kji24xj53fdprg845j7m3s5h9vglv9016im4bbbbpr87ccrzzja";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "144ry9jd2klvzw6nlyk1rja0ijqf6x1mmp1qqwcsv78r7df5zsxg";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0k7548hii7ns5d8svdnf3gdfs1qsi58bmrclhp9ghsg51mrs3kks";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "125qlaijd75npxisdynnxihqdkb2ynw7hbjxxm824lvzpbnqy2hb";
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
