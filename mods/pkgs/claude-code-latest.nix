{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.168";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "15na5m4czj44mnldjzqi78s5l9ipal0i51zkkkljj60m73z4zhmm";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0q1mjqsam76hcmwvkzww7b8wrybc5az9q8jgbfygmn0hkvaznbl1";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1a5xip2c95i30yycbx07hkv6k7fslk5n6wxd6csfmf5s0gc51srd";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1iq264f3whmjivl246m65k1bhwcmlhy7hryxvjcjxpy76bx1y8w0";
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
