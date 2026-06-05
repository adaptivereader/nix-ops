{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.163";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "18mbnppg40ckhdi6xc9dhm0999hynjnchvda64d5hff2xk69dizj";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0idg6la8374q1zn60fz950pqfqaqp7kymaxp3jhd45h04idzwlmw";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1f0z541yhqmlzi8whx0c4qd7cfwvjqmizh1zjml8hqnrmpsdqhml";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1s7m8y89j4rwj3q2wbxn2r8jkxg69jvfmy3l3qc91ma87rry0vgc";
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
