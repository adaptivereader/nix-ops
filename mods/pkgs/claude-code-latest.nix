{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.183";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0l8iqrx468fpvxrkv6r2xazqg0885yrmywm94cp0jc235bakp1qb";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1iikw9n61ckyq3mzlb2cg26gm13idkzf4ydi5yhzxghd187kr0ll";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1ph60qahcm75kl3gqqvl82wz8pr9pk7n582y282yscicrqd310s2";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0c6j6hhqbg7a7hnap2lgr8i1flvhqmky73j9hpjpjl9mp7k399wx";
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
