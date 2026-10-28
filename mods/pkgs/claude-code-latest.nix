{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.312";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0am63zikf5mb3nyk0j0mc2fi7sxa5sxhkwaq0wnxmnswgim5km2z";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0m6kssr1wiiwghhhlqn07srwvny0p5cynjacfvzw2x5xq4i8dpzj";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1zbbiir2s4m0cl598ijyn7m2zryx6f46774b1c4fgirszwixkhzi";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0p4y7lqs506m3q5dpbzi4j7idlwmms1rn077a6l7g2jyscjfda1s";
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
