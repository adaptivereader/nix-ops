{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.281";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "06ydhz32z8g39wkba9ifdk87lfhzqyf0kzj98ll1kb8fkqr3sqly";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1p95k7j2f6bkw19c5yz864sdmpc1igrvfqfp7w1wpz2ww5al784s";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0jnp3nixj1z6gnnb9hh60snphvjcm94jxjjvk2211771iifkrnmh";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0ymzgj0mkpgnbaihasd0ajznpi8l39bbmb6vrhl39xqywadni3zr";
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
