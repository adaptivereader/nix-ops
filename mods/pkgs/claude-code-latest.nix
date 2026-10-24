{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.310";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1svj84bh36rdqshlg4qc8dx8ds521nyybcmlgz2aswqjizppn970";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0dfvby2zz8c43vl5fzpldjg2fv7y4wrm65h5r1wyrj32720lvpf8";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1pn65lhr3r5ibv1i9pb94py39f4p93bn2b18vdqb7z881lbv144c";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "11f1n21pazwqnp9ws0kcf4psqw50rj1xqmm6dldh1s37gjjzwjmr";
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
