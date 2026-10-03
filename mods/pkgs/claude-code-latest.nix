{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.288";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1nk450saxp6g7bzc03pl83w774y5fqvij5by6ky5zap64vccpcbw";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1p2kskdyiffilhgaywsfms5gnqgajymlnjm8dlyn81zwf1fa4c7b";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "147sac321p9pymyc8qp5p6m8c5k4k0sj5l9r674g4y6xdcn6lkdm";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0xavrcipv3saih3crl3qchxdsbwwpj7sg89sisbiph0fyc96zr54";
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
