{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.215";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1ch10rayqbrar4194l4cixw8lch4bfpc86124fp7v5cnbh9nmpdm";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0y73j87pcy4k18cwzljkwm1ncpzm6b609s3p76gg5pnkx529yn1a";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "12fjzfmlspnw05blwqnjdkp3gnp6h31db8f9xfkm9jwh5jpd6q6i";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1axp9x0v2k5gmdi6hlg7y05a22sxq5wqdy63zfhw820byda5m2qc";
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
