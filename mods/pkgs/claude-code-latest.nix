{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.278";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "031k5095y3pq19jlb64lxiyn0qri5m84c3cdfsxdc3p9b662ajlk";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "147my99142figvkvwxdhqml5slr0n0hzavllfgbjfmpm22y47crn";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1izicf0assr5qggz7nid5d0w495invbfk3j1gyyx2d021amm3yyi";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "00i32x577q9g97h883cgh98d6f46lfhr9mkl72q1rdww7j2vsm7c";
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
