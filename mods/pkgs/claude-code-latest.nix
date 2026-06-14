{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.177";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1shav3ncy0zfdm1qmqhg8w5i7jgs6sv0b216867h44zgnb9vwdql";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1y4pd779780d03myd810d5mzmi163rjhir5rpz2rgr3rkwdrwsqp";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0940r4yalpd5j9z79q6lv3jzd6c6m9n4hry9bx5am4ssbia1dldw";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0d5jvjxjfn1cz2w133yialw1gk8x5l7ps81fm4l8ax6qjnmjhvyw";
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
