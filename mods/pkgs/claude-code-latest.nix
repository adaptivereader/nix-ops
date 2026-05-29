{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.156";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0wzfi97y68yg9s0fd97hb4vckf339cay67l5gc7ildyvhf8myfd8";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "183ha5x76g5phh3fhlgq3pikbss2mhmqjjzi9j2ciiv38k7jzn3s";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "107gik989lsk3zdlklfmans1p1bmw9xjz1384zcsyfw9djwq5z08";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1dr113z493lq81d6mlggblxqmfbyhmcklgjryd9yaziayzx5w1lp";
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
