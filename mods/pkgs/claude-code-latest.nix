{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.159";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0z56zg0nh2ijb7ikv64fm0w4nk0v902brbm4myvr5z8p9qbg6f2r";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0wpy9ngxixgf26lk2jvh1p02r44ikbbxpdq61vlad39sw45c5jaa";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1w3wc46sa516wbrsmayjjjla34f2hsah2fwygv3v4mg0xznz0vcz";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0w5hxss33789n3m04izgw27fv89bj6vlyd5nlc5k2hhpy4s1cm8b";
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
