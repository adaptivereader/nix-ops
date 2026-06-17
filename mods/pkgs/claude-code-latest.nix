{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.179";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0gwvvkwpjl72wzh09xd6n4jkvwnnni1hajmrffjrzhkm55qzprf8";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0a88fgz8sbqcsvjaimc0v026a40z923sph3q7n8v9babn15zwjpv";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1cfsy0x99jf0qgrzwvk8p13z585vgzrv1bvjxckdildbqzcn39ax";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0jma6vjkknnybsh2chc9kaa1pvx7wrk9rc89dj17flb90jfdi6xm";
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
