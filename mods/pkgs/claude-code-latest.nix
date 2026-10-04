{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.289";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "005pw38jwgqfbc73z62ywz0r8p9sf1782bm72cah9rpd6zrnra0a";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "024kj536wm8kdq923r79fqbmhj62mdck9r98nn1pkn6jsk2fnjji";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0z9k3d4vkbnrn5zh33z53ygzgkcmly5yghbsggxbrzi26i1yp9jh";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1d2ziv18kglk9hc1md0nnrikw1hklxnfhlf6vgzi9gjyjlpivba5";
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
