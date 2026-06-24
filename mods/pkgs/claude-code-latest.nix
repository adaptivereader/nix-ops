{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.187";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "01iikz4k0hf9hm8df05bjlf349hnf40vrcaak9xf20568av7lqn1";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1bd9rbn26ygk7wdh8rjzcxm1q690442hx18ah2wsg0rwslxb3pga";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1qvdrn8y0cdcgmw2ihxnqif92d9glh0qbijxi0n4jicg67ysm5f5";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1xdjrf1kq0dd49yhc7qcrn6n9xh465wqi8l50mkw0hc6m9ppgs7c";
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
