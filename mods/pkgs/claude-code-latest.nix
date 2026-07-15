{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.210";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0d13j6b2cgm0hfm07g6qrkn6cz6dh1p6jhz2xq553vgavc0nw8xr";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "07bq18ka8wr1w1mqvxh9b8lg5p7sxqjnyjqy83yjb37g52364g4c";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1799n9vvzhvkkkkzvhlh3375s7x5czhxysvpiy27cw6yzcw0qv0k";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1v657ah4vjw60wmwh5ma72qb7gg6l2j6wrp55xgxng4panwwnbnd";
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
