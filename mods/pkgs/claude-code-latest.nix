{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.301";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0drgd1dpr1kqs53fkp9p251mlhk32vhqfabiqr0s7wqy3qww6yy6";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0bizddp9wg0i177793ld3mcg7a6j0nnvzir3ivmf3p1j4bppnmwy";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0mqwg2fbbaxl7p5h2lh10vqm1h7cxi6967m3cjldvrl4fwgddzx7";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1l77b1x849y1910qjffw5agm5ckin2hvjpkmyw3y8gm6jvi8hnmq";
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
