{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.260";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0mm0ack6ap8fqgaw6dszrw28yri94cjcmvfzk9530rrv9c52w129";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1xwbnkdmyqv8dnqg62xc23763882ksmjg8dd323hvkhrx5w39789";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1czbmq0f0z4bkxaklxc1jp21fmi7yqry0zfn2xzphi49ggrdyhv8";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0grm0fm9687v5dxhswvbpij87hg6sd963d23jmayb0vzycmd8q2q";
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
