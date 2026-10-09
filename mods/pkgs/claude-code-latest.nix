{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.295";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0hak1qkp70biaijwbvy2db2jdx39v0inh2r8p6di2bwkpzrmjl32";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1dpwf3ik346j81jcd3hrmrlnyyg77i1x05xa09gypj4gcjxqzm6n";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "159xiwa44h9fmgcc8wcc0wbbihlkb3g05ran9ymvi83y9ahjynnl";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0lfbmd4qfd5qdh9mzhi5flwwczd2m7dc58ymqhpns10697g687lk";
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
