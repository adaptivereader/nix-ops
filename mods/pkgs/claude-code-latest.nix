{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.229";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0ngvhv2lr5599qq1d3j51acgl8lai9nd727wsa2ya60z4c1k5gyq";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0jsywwqz2xd90032jqvvald49cx89xv13w9xkh9sqwhw992vs341";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1xj7ypa2mdv48kqvnvhskhnsaksiyy85pzxm60ckbpramw8bn11m";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "10cpg5ixy8xmsws353klnang3n6w8qnsjqqv5kf2p4b71pid31hn";
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
