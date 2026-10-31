{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.314";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "032pm9q5y4zn2bria29svnilbk13w5qcnpjbi6j7j71zjqi48lp4";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1mmqjadcqz525y0k9jl86if9f31r8jg19n545zl179nig881s17h";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0y1bih4afr54gzazf8a3bjcz9kjsqcp6nmnjr323il525gjr1dn6";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1p5hakl19sd76iaa9bhnibr5hz33i5p8rrdqdcr9cmyzn3v8g02s";
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
