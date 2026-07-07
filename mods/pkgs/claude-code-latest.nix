{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.202";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0wh36qpm766fqirx9c1gzbc94f7m05gbrrdz4ykhiwlydgxxvyhq";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "181ibk163284lsx50y59cqr48y18bb6kj35wfmvjx9a56m3zr9w1";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0ci81zrd3s2h5w5ngfhmgjps4vx444jiqbid1wamh81nhgjqgpr2";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1rv0fvkj77jmvihi0h99403619ahhlkwaa0yh4fcn6vyffwi2r04";
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
