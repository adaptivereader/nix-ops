{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.216";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "05607bj7vxbc3a4vd1qjq1y0pljpkr071qcj2qgc6nc6xpcmvgvy";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0lwvilg1wmyv0pg5x6ryj3qy7sdy7fcr5cql1zwgjqvkjz4mi637";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0jr9dzvk1mc4rzy328xhclx8mx7chqi2b9x20vh28bryka85sx9s";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1v6294lg50frsq8bgf2if9c40rm73rwd5ld4iqzv4sp0nf1m2nxr";
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
