{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.132";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1sgp867gv3cjnvqxcwh67zh5ayls98z00h5k9yra5rfk4sdnvgha";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "19628gdj6y9fhkr2kdxydp8h4w44q52s2jmgyig77lcp38r8sr43";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "15m4dc9c19xx53jm9bfpmb0hic2f3pw5h49prys7byivrgmw3n28";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "02hvz7yin7w5yhk5v1ymcxf6rj005977z6q637b1fqpg1lkcycvq";
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
