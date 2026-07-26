{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.220";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1dmrdb2g1ricg7rxdpxlnma6rxpqicpgzcdkvfqjl6ijxsnzhfmd";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0hxwdyybd1vcr6afpbnagqkr5922r4awa9rw7dmgbm3xzyp0hx5h";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "03dd4x9c0p9r0nrimyjywian9ha57kl05nphxb7dblfkwv5f5li5";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0kc8mh8fifx2b1fcla02i4zg77pwfffm69kzf0p8m83n6pbm9173";
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
