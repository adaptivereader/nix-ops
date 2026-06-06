{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.166";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "18kykgw9wbvh4bx0h3gpp92qh60s22jw8lrh3z7pfcykzkp1dhcg";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "07p7iii1v80zk50sqgfm6aa9agx7dar6zpwx2ayrmanclvwrsfhj";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0v38ndpz45qn439q22pnv7p0i9rrfrcd55bb8pzms7mskp39pj19";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0axfa27fgdyql6gmyjzqq8c28ag853mnnsn3asaf5ldiwfb8nn0s";
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
