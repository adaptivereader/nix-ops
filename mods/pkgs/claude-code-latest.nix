{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.195";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0mggi8mbji9qw0l1sscpfm1agg8p3rqmwc7n3194w3c615yhb9ga";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0s1j1jcvidf4f9h65irbylmf26gmhajmivf0ghsxpvl8hm7pax10";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1fxq72z1r9d8vnkd10rwj4h6lsy8irw0nx2adlsgfx87jl9jghyf";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "009mv31b4hlwx9kxg173j58vhc25zla05wp9b201ikypx0kzizrv";
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
