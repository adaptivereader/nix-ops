{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.126";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1y559f681a4q9lwakdy94r8b9xyf19sygslvsgys71r9xlipxwcf";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1z6gdawjh8adp48sykwc5yrjd6mhihpdy89ccny6fdhbzjdrma0a";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "07srrbiwzc6gvarwvybia5is082472ykrgrz79chyb50qyymajky";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0mcqx5bn2l5i69y8nxk35nvkm5x6ck43yhh47kpxrnbyq5nqlgjw";
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
