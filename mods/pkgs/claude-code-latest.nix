{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.140";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "12jxl3nc480fcwbhffpfyxrysfp096gs7rd022brbn10l9dc6wi6";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1sf5d5jgfkfpclqk16f8iq5f2x08c6y7qfm25dz44v8dsq39jfma";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "14ksa8vrqb8y92wy5mf72fw86w6rkvr188fb9givrs6b2pyxag3i";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1f3wa4ihmj089j90w52np3r472qpb517xh6jdzr5ffn7d35dvqxk";
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
