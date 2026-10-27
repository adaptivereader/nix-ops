{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.311";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0a88jc30h8v0q2qlwq6qy6acihmz3mrwg67rrpmybzzh7ywpfjla";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0h55xi74924m37nzrpr04d0wwf2qjfj3ycmr394jd5bmicf8bwma";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0mhvvw1h0y8b6yw82yjabq4c1g8j29gs2j2kab2n6c53z48wcls3";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1r9ns931s98s39w250h70xf8xpf1pvhm3v1xry1d75gk498khkw0";
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
