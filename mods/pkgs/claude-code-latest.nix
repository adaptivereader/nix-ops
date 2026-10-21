{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.305";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0hkvi0g61qrngfs40wnv3zhxckr62kcjcysh2071akiv7wr7cdn5";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1czdh8d7bq2i7cq1h9lfk9w00g1d7cvcjf87m0f650q78qvcindg";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0jl9mq609h7aq08gicmajbcwlz8kvn29k7rr7rgkwqmraclks4kd";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1ajqr5nbpv07g3rmbprr56rnmzp4q7qjl8vpdy0jpl44g5qdfk2h";
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
