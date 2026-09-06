{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.263";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0bpk4zqwhly4h9b8mbnr64fkrl1ns1pim7bxz0kdpb291vdd5h7i";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0cxgrwzpw7g3xw8d568hwg9daq7ak5j83w2w3wy4vzkdgqzxf14q";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0i89dmxil6lzysbvzhf6w9nf1pzhrzvx22js13gdqvymi8s0fqlb";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0k6446jk9jqh8vp1y8xaxsfbi5isdvxibzh6w1yb2s29nvk8n8v4";
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
