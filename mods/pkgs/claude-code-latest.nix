{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.303";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "06vy0f81mghbqhnzgf6k5pysxpnjkdn8w8nx81bsxjavi5494yw6";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "11nw981ya528mrr4jvlrhl5qrxdnqhfqcj2bxmryzm85vzzs3jyk";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1ws31c6m7c73d2m8gr0mhw3xzf55bxi1pg8xlfa2z238djgky1rb";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "124g89vm4n3rlcm69vigx4zby2c2m7vi514zqxh1cmf08zc7rdic";
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
