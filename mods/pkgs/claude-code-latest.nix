{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.241";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "167azlnmibvmvyg6l90hyb702rqwhh0n5yy8amcz7vsarg15c1hq";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0481wfsb4la73j5p6izxyjd8sh5p6c61s8gwlb84rnp72pj00shs";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0d4fblm32lnhp2iwiz9a8406w1wcjib71czaggq1hhy8g33wlvgr";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "16j171g0kx8dn4c197b5fxdy3kzm3xd9shb0a1dvqrr6cxp8kpj1";
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
